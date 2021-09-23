import GRDB
import BakingRecipeFoundation

//grants acces to the recipes database
class RecipesManager {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }

}

// Feeds the list of recipes
//extension RecipesManager {
//    struct RecipeListItem: Decodable, FetchableRecord {
//        let recipe: Recipe
//        let stepCount: Int
//
//        static var request = Recipe.annotated(with: Recipe.steps.count).orderedByNumber
//    }
//
//    func recipeList() throws -> [RecipeListItem] {
//        try dbPool.read { db in
//            try RecipeListItem.fetchAll(db, RecipeListItem.request)
//        }
//    }
//
//    var recipeListPublisher: DatabasePublishers.Value<[RecipeListItem]> {
//        ValueObservation
//            .tracking { db in
//                try RecipeListItem.fetchAll(db, RecipeListItem.request)
//            }
//            .publisher(in: dbPool)
//    }
//}

// feeds a recipe screen
extension RecipesManager {
    struct RecipeInfo: Decodable, FetchableRecord {
        var recipe: Recipe
        var steps: [Step]
    }

    func recipeInfo(recipeId: Int64, db: Database) throws -> RecipeInfo? {
        try dbPool.read { db in
            guard let recipe = try Recipe.fetchOne(db, id: recipeId) else {
                return nil
            }

            let steps = try recipe.steps.fetchAll(db)
            return RecipeInfo(recipe: recipe, steps: steps)
        }
    }
}

//feeds a step screen
extension RecipesManager {
    struct StepInfo {
        var step: Step
        var substeps: [Step]
        var ingredients: [Ingredient]
    }

    func stepInfo(stepId: Int64) throws -> StepInfo? {
        try dbPool.read { db in
            guard let step = try Step.fetchOne(db, id: stepId) else {
                return nil
            }

            let substeps = try step.substeps.fetchAll(db)
            let ingredients = try step.ingredients.fetchAll(db)
            return StepInfo(step: step, substeps: substeps, ingredients: ingredients)
        }
    }
}
