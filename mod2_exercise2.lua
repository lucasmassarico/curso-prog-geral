local table_utils = require("table_utils")

local craftRecipes = {
  {
    name = 'chair', 
    ingredients = {
      { name = 'wood', count = 4 },
      { name = 'paint', count = 1 },
      { name = 'nail', count = 4 },
    },
  },
  {
    name = 'table', 
    ingredients = {
      { name = 'wood', count = 8 },
      { name = 'paint', count = 1 },
      { name = 'nail', count = 4 },
    },
  },
  {
    name = 'halloween costume', 
    ingredients = {
      { name = 'pumpkin', count = 1 },
      { name = 'cloth', count = 8 },
    },
  },
  {
    name = 'stone axe',
    ingredients = {
      { name = 'wood', count = 2 },
      { name = 'stone', count = 2 },
    },
  },
}

local craftsByIngredient = {}

function setupCraftsByIngredient()
  craftsByIngredient = {}

  for index, recipe in ipairs(craftRecipes) do

    for _, ingredient in ipairs(recipe.ingredients) do
      local ingredientName = ingredient.name

      if not craftsByIngredient[ingredientName] then
        craftsByIngredient[ingredientName] = {}
      end

      craftsByIngredient[ingredientName][#craftsByIngredient[ingredientName] + 1] = index
    end
  end
end

function getRecipes()
  return craftRecipes
end

function getRecipesByIngredientName(name)
  local recipeIndexes = craftsByIngredient[name] or {}
  local recipes = {}

  for _, recipeIndex in ipairs(recipeIndexes) do
    table.insert(recipes, craftRecipes[recipeIndex])
  end

  return recipes
end

local function canCraftRecipe(recipe, inventoryByName)
  for _, ingredient in ipairs(recipe.ingredients) do
    local availableCount = inventoryByName[ingredient.name] or 0

    if availableCount < ingredient.count then
      return false
    end
  end
  
  return true
end

function getAvailableRecipes(ingredients)
  local inventoryByName = {}
  local candidateRecipesSet = {}
  local candidateRecipesList = {}

  for _, ingredient in ipairs(ingredients) do
    inventoryByName[ingredient.name] = (inventoryByName[ingredient.name] or 0) + ingredient.count

    local recipeIndexes = craftsByIngredient[ingredient.name] or {}

    for _, recipeIndex in ipairs(recipeIndexes) do
      if not candidateRecipesSet[recipeIndex] then
        candidateRecipesSet[recipeIndex] = true
        candidateRecipesList[#candidateRecipesList + 1] = recipeIndex
      end
    end
  end

  local availableRecipes = {}

  for _, recipeIndex in ipairs(candidateRecipesList) do
    local recipe = craftRecipes[recipeIndex]

    if recipe and canCraftRecipe(recipe, inventoryByName) then
      availableRecipes[#availableRecipes + 1] = recipe
    end
  end

  return availableRecipes
end

function main()
  setupCraftsByIngredient()
  -- print(table_utils.tostring(craftsByIngredient))

  local recipes = getRecipesByIngredientName("wood")
  -- print(table_utils.tostring(recipes))

  local availableRecipes = getAvailableRecipes({
    { name = 'wood', count = 15 },
    { name = 'nail', count = 4 },
    { name = 'paint', count = 30 },
    { name = 'stone', count = 50 }
  })
  -- print(table_utils.tostring(availableRecipes))

end

main()
