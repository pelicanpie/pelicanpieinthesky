# Recipe Database Design

### Use Cases
What use cases do I want this app to fulfil. \
A lot of detail can be referred to in this blog post: https://stormotion.io/blog/how-to-build-a-cooking-or-recipe-app/
1. As a user I want to be able to view all recipes so that I can browse for ones I am interested in
2. As a user I want to be able to filter recipes per categories such as meal type - breakfast/lunch/dessert/dinner so that I can find recipes based on the type of meal I want to prepare
3. As a user I want to be able to filter recipes by ingredient so that I can view recipes with what I have available
4. As a user I want to create and manage a shopping list of ingredients so that I can tick off ingredients that I need to buy
5. As a user I want to be guided through the cooking process with key information such as ingredients, photos, instructions per step so that I don't need to keep flicking between screens
6. As a user I want to be able to select the units displayed - F/C, Empirical/Metric, Volume/Weight so that I can read recipes in a way that makes sense to me
7. As a user I want to be able to scale recipe ingredients based on servings so that I don't have to calculate each measurement
8. As a user I want to store notes about each recipe with date and modification information so I can track what I learn about each recipe
9. As a site manager I want to be able to upload recipes easily via a browser based app so that I don't have to think in json/yml
10. As a site manager I want my recipes to be automatically tagged wherever possible so that the recipes are searchable with less manual input
11. (Bonus) Hands Free! Alexa?
12. (Food scanner) As a user I want to be able to take a photo of my ingredients and the app will tell me if I'm missing anything
\
The key requirements for database design will come from how the front end will interact with it. \
The front end will be organised into components:
- Recipe overview metadata
- Ingredients list
- Method
- Method step iteration?
- Recipe Notes
 
The database will need to be queried in the following ways
- select all Recipe Metadata
- select all Recipes where Ingredients include...
- select all Recipes where Tags include...
- select all Ingredients for this Recipe
- select all Method steps for this Recipe
- select all Notes for this Recipe

## Initial Decisions
### Relational vs NoSQL
A lot of the searches online for recipe database design immediately turn to relational databases. I think the only result that came up for a noSQL design was a masters paper submitted to California State Polytechnic University. \
I suppose that makes sense, for recipes you need to store ingredients and the method steps and while the main way the data will be accessed is per recipe, there will be cases when you want to search all recipes involving certain ingredients.

#### Can this be done in NoSql?
Could this document design work?
- Recipe DB
    - Recipe
        - Metadata
            - Title
            - Description
            - Author
            - Reference
            - Total Time
            - Cooking Method
            - Rating
        - Ingredient_Hash
                - (Ingredient object)
        - Ingredient_Hash2
                - (Ingredient object)
        - Steps
            - Index
                - (Instruction object)
        - Tag_Hash
            - tag_value
        - Notes
            - createdDateTime
                - (Note object)

#### Object reference
- Ingredient object
    - Ing_Name
    - Quantity
    - Measure
    - Preparation
- Instruction object
    - Index
    - Instruction
    - Related Ingredient object id's
    - Time
- Notes object
    - Note
    - CreatedDateTime
    - Author

#### Test queries
- select all Recipe Metadata:
    - Scan
    - "ProjectionExpression": ["Metadata","Tags"]
- select all Recipes where Ingredients include...
    - Scan
    - "ProjectionExpression": ["Metadata","Tags"]
    - "FilterExpression": "Ingredients.name = :ingredient"
- select all Recipes where Tags include...
    - Scan
    - "ProjectionExpression": ["Metadata","Tags"]
    - "FilterExpression": "Tags = :tag"
- select all Ingredients for this Recipe
    - Query
    - "ProjectionExpression": "Ingredients"
    - "KeyConditionExpression": "RecipeId = :recipeid"
- select all Method steps for this Recipe
    - Query
    - "ProjectionExpression": "Steps"
    - "KeyConditionExpression": "RecipeId = :recipeid"
- select all Notes for this Recipe
    - Query
    - "ProjectionExpression": "Notes"
    - "KeyConditionExpression": "RecipeId = :recipeid"

#### Thoughts
##### Scan queries are expensive.
To reduce their cost can we split into different tables? \
- sweet and savoury?
- Meal type? 
Unlikely to be querying across all (except maybe tag = breakfast or tag = sweet/dessert)? \

##### Secondary indexes
Secondary indexes do not support many to many relationships. \
AWS has the concept of an Adjacency list pattern: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-adjacency-graphs.html#bp-adjacency-lists \
We want to reduce the cost of querying by tag and by ingredient. \

GSI overloading + sparse index?

Base table
PK: recipe_id
SK: various
Ingredient attribute name: ing_name

GSI1
PK: ing_name
SK: recipe_id

GSI2
PK: tag_value
SK: recipe_id