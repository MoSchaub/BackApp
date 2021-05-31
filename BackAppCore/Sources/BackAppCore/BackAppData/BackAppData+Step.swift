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
        self.allObjects(type: Step.self)
    }
    
    ///all steps in a recipe
    func steps(with recipeId: Int) -> [Step] {
        self.allObjects(type: Step.self, filter: .equalsValue(Step.recipeId, recipeId))
    }
    
    func stepsWithIngredientsOrSupersteps(in recipeId: Int, without stepId: Int) -> [Step] {
        let stepIdsOfIngredients = allIngredients.map { $0.stepId }
        
        let substeps = allObjects(type: Step.self, filter: Step.superStepId != Null())
        let superstepIds = substeps.map { $0.superStepId! }
        
        let stepIdsWithIngredientsOrSubsteps: Set<Int> = Set(stepIdsOfIngredients + superstepIds).filter({ $0 != stepId })
        
        return stepIdsWithIngredientsOrSubsteps.map { object(with: $0, of: Step.self)!}.filter({ $0.recipeId == recipeId })
    }
    
    func moveStep(with recipeId: Int, from source: Int, to destination: Int) {
        self.moveObject(in: reorderedSteps(for: recipeId), from: source, to: destination)
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
    
    ///mass of all Ingredients and Substeps of a step in a given database
    func totalMass(for stepId: Int) -> Double {
        findStepAndReturnAttribute(for: stepId, failValue: 0) { step in
            step.totalMass(db: database)
        }
    }
    
    /// the mass of all ingredients and substeps of a step formatted with the right unit
    func totalFormattedMass(for stepId: Int, factor: Double = 1) -> String {
        findStepAndReturnAttribute(for: stepId, failValue: "") { step in
            step.totalFormattedMass(db: database, factor: factor)
        }
    }
    
    ///temperature for bulk liquids so the step has the right temperature
    func temperature(for ingredient: Ingredient, roomTemp: Double) -> Double {
        let kneadingHeating = Standarts.kneadingHeatingEnabled ? Standarts.kneadingHeating : 0.0
        return findStepAndReturnAttribute(for: ingredient.stepId, failValue: 0) { step in
            step.temperature(for: ingredient, roomTemp: roomTemp, kneadingHeating: kneadingHeating, db: database)
        }
    }
    
    func flourMass(for stepId: Int) -> Double {
        findStepAndReturnAttribute(for: stepId, failValue: 0) { step in
            step.flourMass(db: database)
        }
    }
    
    func waterMass(for stepId: Int) -> Double {
        findStepAndReturnAttribute(for: stepId, failValue: 0) { step in
            step.waterMass(db: database)
        }
    }
    
}
