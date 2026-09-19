import sys
import json
import collections

def isSequentialCellType(cellType):
    lowerCellType = cellType.lower()
    return "dff" in lowerCellType or "latch" in lowerCellType or cellType.startswith("$mem")

def isTopModule(moduleData):
    topAttribute = moduleData.get("attributes", {}).get("top")
    return topAttribute is not None and int(topAttribute, 2) == 1

def loadTopModule(netlistPath):
    with open(netlistPath) as netlistFile:
        netlistData = json.load(netlistFile)
    for moduleName, moduleData in netlistData["modules"].items():
        if isTopModule(moduleData):
            return moduleName, moduleData
    raise ValueError("no module in the netlist is marked as top")

def collectBitDrivers(topModule):
    bitDriverCell = {}
    bitConsumerCells = collections.defaultdict(list)
    for cellName, cellData in topModule["cells"].items():
        portDirections = cellData["port_directions"]
        connections = cellData["connections"]
        for portName, bitList in connections.items():
            direction = portDirections.get(portName, "input")
            for bitValue in bitList:
                if not isinstance(bitValue, int):
                    continue
                if direction == "output":
                    bitDriverCell[bitValue] = cellName
                else:
                    bitConsumerCells[bitValue].append((cellName, portName))
    return bitDriverCell, bitConsumerCells

def buildCellLevelGraph(topModule, bitDriverCell):
    combinationalPredecessors = collections.defaultdict(set)
    for cellName, cellData in topModule["cells"].items():
        if isSequentialCellType(cellData["type"]):
            continue
        portDirections = cellData["port_directions"]
        connections = cellData["connections"]
        for portName, bitList in connections.items():
            if portDirections.get(portName, "input") != "input":
                continue
            for bitValue in bitList:
                if not isinstance(bitValue, int):
                    continue
                driverCellName = bitDriverCell.get(bitValue)
                if driverCellName is None:
                    continue
                driverCellData = topModule["cells"][driverCellName]
                if isSequentialCellType(driverCellData["type"]):
                    continue
                combinationalPredecessors[cellName].add(driverCellName)
    return combinationalPredecessors

def computeLogicDepth(topModule, combinationalPredecessors):
    memoizedDepth = {}

    def combinationalDepth(cellName, visitingSet):
        if cellName in memoizedDepth:
            return memoizedDepth[cellName]
        if cellName in visitingSet:
            return 0
        visitingSet.add(cellName)
        maxUpstreamDepth = 0
        for predecessorCellName in combinationalPredecessors.get(cellName, ()):
            maxUpstreamDepth = max(maxUpstreamDepth, combinationalDepth(predecessorCellName, visitingSet))
        visitingSet.discard(cellName)
        depthValue = maxUpstreamDepth + 1
        memoizedDepth[cellName] = depthValue
        return depthValue

    deepestCellName = None
    deepestDepth = 0
    for cellName, cellData in topModule["cells"].items():
        if isSequentialCellType(cellData["type"]):
            continue
        depthValue = combinationalDepth(cellName, set())
        if depthValue > deepestDepth:
            deepestDepth = depthValue
            deepestCellName = cellName
    return deepestDepth, deepestCellName

def buildBitLabels(topModule):
    bitLabel = {}
    for netName, netData in topModule.get("netnames", {}).items():
        for bitValue in netData["bits"]:
            if isinstance(bitValue, int) and bitValue not in bitLabel:
                bitLabel[bitValue] = netName
    return bitLabel

def printCellTypeHistogram(topModule):
    cellTypeCount = collections.Counter(cellData["type"] for cellData in topModule["cells"].values())
    print("Cell type histogram:")
    for cellType, count in cellTypeCount.most_common():
        print(f"  {cellType:20s} {count}")
    print(f"Total cells: {len(topModule['cells'])}")

def printGraphSize(bitDriverCell, bitConsumerCells):
    edgeCount = sum(len(consumers) for consumers in bitConsumerCells.values())
    print(f"DAG nodes (nets with a known driver): {len(bitDriverCell)}")
    print(f"DAG edges (driver-to-consumer bit connections): {edgeCount}")

def printLogicDepth(topModule, combinationalPredecessors):
    deepestDepth, deepestCellName = computeLogicDepth(topModule, combinationalPredecessors)
    print(f"Longest combinational chain: {deepestDepth} cell-hops, ending at cell '{deepestCellName}'")

def printTopFanoutNets(bitConsumerCells, bitLabel, topCount):
    fanoutList = sorted(bitConsumerCells.items(), key=lambda entry: len(entry[1]), reverse=True)
    print(f"Top {topCount} highest fan-out nets:")
    for bitValue, consumers in fanoutList[:topCount]:
        label = bitLabel.get(bitValue, f"bit{bitValue}")
        print(f"  {label:30s} fan-out={len(consumers)}")

def main():
    netlistPath = sys.argv[1] if len(sys.argv) > 1 else "build/synth/Rv32iCore.json"
    topModuleName, topModule = loadTopModule(netlistPath)
    print(f"Top module: {topModuleName}")
    printCellTypeHistogram(topModule)
    bitDriverCell, bitConsumerCells = collectBitDrivers(topModule)
    printGraphSize(bitDriverCell, bitConsumerCells)
    combinationalPredecessors = buildCellLevelGraph(topModule, bitDriverCell)
    printLogicDepth(topModule, combinationalPredecessors)
    bitLabel = buildBitLabels(topModule)
    printTopFanoutNets(bitConsumerCells, bitLabel, 15)

if __name__ == "__main__":
    main()
