//
//  BackAppData+Step.swift
//  
//
//  Created by Moritz Schaub on 22.12.20.
//

import BakingRecipeFoundation
import Sqlable

public extension BackAppData {
    
    ///all steps in the database
    var allSteps: [Step] {
        (try? Step.read().run(database)) ?? []
    }
    
    ///all steps in a recipe
    func steps(with recipeId: Int) -> [Step] {
        (try? Step.read().filter(.equalsValue(Step.recipeId, recipeId)).run(database)) ?? []
    }
    
}

//MARK: - Wrapper for Step attributes
public extension BackAppData {
    
    ///func to reduce code duplication
    private func findStepAndReturnAttribute<T>(for stepId: Int, failValue: T, successCompletion: ((Step) -> T) ) -> T {
        guard let step = self.allSteps.first(where: { $0.id == stepId }) else {
            return failValue
        }
        
        return successCompletion(step)
    }
    
    ///substeps of a Step
    func substeps(for stepId: Int) -> [Step] {
        findStepAndReturnAttribute(for: stepId, failValue: []) { step in
            step.substeps(db: database)
        }
    }
    
    /// substeps of a step sorted by their duration in descending order
    func sortedSubsteps(for stepId: Int) -> [Step] {
        findStepAndReturnAttribute(for: stepId, failValue: []) { step in
            step.sortedSubsteps(db: database)
        }
    }
    
    ///substeps of a step ordered by their duration in descending order in combination with this step.
    ///This order makes sense when doing the substeps and this step
    ///because the substeps are going parrellel and so the longest step has to start first
    func stepsForReodering(for stepId: Int) -> [Step] {
        findStepAndReturnAttribute(for: stepId, failValue: []) { step in
            step.stepsForReodering(db: database)
        }
    }
    
    ///mass of all Ingredients and Substeps of a step in a given database
    func totalMass(for stepId: Int) -> Double {
        findStepAndReturnAttribute(for: stepId, failValue: 0) { step in
            step.totalMass(db: database)
        }
    }
    
    /// the mass of all ingredients and substeps of a step formatted with the right unit
    func totalFormattedMass(for stepId: Int) -> String {
        findStepAndReturnAttribute(for: stepId, failValue: "") { step in
            step.totalFormattedMass(db: database)
        }
    }
    
    ///temperature for bulk liquids so the step has the right temperature
    func temperature(for ingredient: Ingredient, roomTemp: Int, for stepId: Int) -> Int {
        findStepAndReturnAttribute(for: stepId, failValue: 0) { step in
            step.temperature(for: ingredient, roomTemp: roomTemp, db: database)
        }
    }
    
}
