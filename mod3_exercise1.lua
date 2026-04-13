local sampleNames = { "Maria", "Lucia", "Arthur", "Boris", "Newton" }
local testN = 10000
local users = {}

local function findInsertIndex(name)
  local left = 1
  local right = #users

  while left <= right do
    local mid = math.floor((left + right) / 2)

    if users[mid].name < name then
      left = mid + 1
    else
      right = mid - 1
    end
  end

  return left
end

local function merge(left, right)
  local result = {}
  local i = 1
  local j = 1

  while i <= #left and j <= #right do
    if left[i].name < right[j].name then
      table.insert(result, left[i])
      i = i + 1
    else
      table.insert(result, right[j])
      j = j + 1
    end
  end

  while i <= #left do
    table.insert(result, left[i])
    i = i + 1
  end

  while j <= #right do
    table.insert(result, right[j])
    j = j + 1
  end

  return result
end

function registerUser(name)
  local lowerName = string.lower(name)
  local newUser = { id = #users, name = lowerName }
  local index = findInsertIndex(lowerName)
  table.insert(users, index, newUser)
end

function registerUsers(names)
  local batch = {}
  local startId = #users

  for i, name in ipairs(names) do
    batch[i] = {
      id = startId + (i - 1),
      name = string.lower(name)
    }
  end

  table.sort(batch, function(a, b) return a.name < b.name end)

  users = merge(users, batch)
end

function main()
  local names = {}
  local n = #sampleNames
  for i=1,testN do
    names[i] = sampleNames[((i-1) % n)+1]  .. i
  end

  registerUser('Fulano')
  registerUsers(names)
  registerUser('Beltrano')
  print('Users registered: ', #users)
end

local t0 = os.clock()
main()
local t1 = os.clock()

local elapsedMs = (t1 - t0) * 1000
print(string.format("Time to execute: %.2f ms", elapsedMs))
