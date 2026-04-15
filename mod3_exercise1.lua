local sampleNames = { "Maria", "Lucia", "Arthur", "Boris", "Newton" }
local testN = 10000
local users = {}

function registerUser(name, shouldSort)
  local lowerName = string.lower(name)
  table.insert(users, { id = #users, name = lowerName })

  if shouldSort ~= false then
    table.sort(users, function(a, b) return a.name < b.name end)
  end
end

function registerUsers(names)
  local count = #names

  for index,name in ipairs(names) do
    if index == count then
      registerUser(name, true)
    else
      registerUser(name, false)
    end
  end
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
