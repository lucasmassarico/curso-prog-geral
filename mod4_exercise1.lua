local numbers = {}

local function partition(array, left, right)
  local pivot = array[right]
  local i = left - 1

  for j = left, right - 1 do
    if array[j] <= pivot then
      i = i + 1

      array[i], array[j] = array[j], array[i]
    end
  end

  array[i + 1], array[right] = array[right], array[i + 1]

  return i + 1
end

local function partitionRandomPivot(array, left, right)
  local randomIndex = math.random(left, right)

  array[randomIndex], array[right] = array[right], array[randomIndex]
  return partition(array, left, right)
end

local function quickSort(array, left, right)
  if left < right then
    local pivotIndex = partition(array, left, right)

    quickSort(array, left, pivotIndex - 1)
    quickSort(array, pivotIndex + 1, right)
  end

  return array
end

local function quickSortRandom(array, left, right)
  if left < right then
    local pivotIndex = partitionRandomPivot(array, left, right)

    quickSortRandom(array, left, pivotIndex - 1)
    quickSortRandom(array, pivotIndex + 1, right)
  end

  return array
end

local function buildWorstCaseArray(size)
  numbers = {}

  for i=1, size do
    table.insert(numbers, i)
  end

  -- or
  -- numbers = {1, 2, 3, 4, 5, 6, 7, 8}
end

local function buildBalancedCaseArray()
  numbers = {}

  numbers = { 4, 2, 7, 1, 3, 6, 8, 5 }
end

local function copyArray(array)
  local copy = {}

  for i=1, #array do
    copy[i] = array[i]
  end
  return copy
end


local function main()
  local size = 10000

  buildWorstCaseArray(size)

  local array1 = copyArray(numbers)
  local array2 = copyArray(numbers)

  local t0 = os.clock()
  quickSortRandom(array2, 1, #array2)
  local t1 = os.clock()


  local t2 = os.clock()
  quickSort(array1, 1, #array1)
  local t3 = os.clock()

  print(string.format("QuickSort Random Pivot: %.2f ms", (t1 - t0) * 1000))
  print(string.format("QuickSort: %.2f ms", (t3 - t2) * 1000))
end


math.randomseed(os.time())
main()
