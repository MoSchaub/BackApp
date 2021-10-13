//
//  BackAppData+Step.swift
//  
//
//  Created by Moritz Schaub on 22.12.20.
//

import BakingRecipeFoundation
import GRDB

public extension BackAppData {
    
    ///all steps in the database
    var allSteps: [Step] {
        self.allRecords()
    }
    
    ///all steps in a recipe orderered by number
    func steps(with recipeId: Int64) -> [Step] {
        (try? self.databaseReader.read { db in
            try? Step.all().orderedByNumber(with: recipeId).fetchAll(db)
        }) ?? []
    }
    
    func stepsWithIngredientsOrSupersteps(in recipeId: Int64, without stepId: Int64) -> [Step] {
        ///get the step ids that contain ingredients
        /// - NOTE:  a step can appear multiple times
        let stepIdsOfIngredients = allIngredients.map { $0.stepId }
        
        ///get all thes step ids that have substeps
        /// step ids can appear multiple times
        let substeps = steps(with: recipeId).filter {$0.superStepId != nil}
        let superstepIds = substeps.map { $0.superStepId! }
        
        //put them together and make them unique with a set and filter out the current step and steps of other recipes
        let stepIdsWithIngredientsOrSubsteps: Set<Int64> = Set(stepIdsOfIngredients + superstepIds).filter({ $0 != stepId }).filter { id in  self.steps(with: recipeId).map{ step in step.id}.contains(id)}
        //convert the ids to steps
        let stepsWithIngredientsOrSubsteps = stepIdsWithIngredientsOrSubsteps.map { id in self.steps(with: recipeId).first(where: { step in step.id == id})!}
        
        return stepsWithIngredientsOrSubsteps
    }
    
    func moveStep(with recipeId: Int64, from source: Int, to destination: Int) {
        self.moveRecord(in: steps(with: recipeId), from: source, to: destination)
    }
    
}

//MARK: - Wrapper for Step attributes
public extension BackAppData {
    
    ///func to reduce code duplication
    private func findStepAndReturnAttribute<T>(for stepId: Int64, failValue: T, successCompletion: ((Step) -> T) ) -> T {
        guard let step = self.allSteps.first(where: { $0.id == stepId }) else {
            return failValue
        }
        
        return successCompletion(step)
    }
    
    /// substeps of a step sorted by their duration in descending order
    func sortedSubsteps(for stepId: Int64) -> [Step] {
        findStepAndReturnAttribute(for: stepId, failValue: []) { step in
            step.sortedSubsteps(reader: databaseReader)
        }
    }
    
    ///mass of all Ingredients and Substeps of a step in a given database
    func totalMass(for stepId: Int64) -> Double {
        findStepAndReturnAttribute(for: stepId, failValue: 0) { step in
            step.totalMass(reader: databaseReader)
        }
    }
    
    /// the mass of all ingredients and substeps of a step formatted with the right unit
    func totalFormattedMass(for stepId: Int64, factor: Double = 1) -> String {
        findStepAndReturnAttribute(for: stepId, failValue: "") { step in
            step.totalFormattedMass(reader: databaseReader, factor: factor)
        }
    }
    
    ///temperature for bulk liquids so the step has the right temperature
    func temperature(for ingredient: Ingredient, roomTemp: Double) -> Double {
        let kneadingHeating = Standarts.kneadingHeatingEnabled ? Standarts.kneadingHeating : 0.0
        return findStepAndReturnAttribute(for: ingredient.stepId, failValue: 0) { step in
            (try? step.bulkLiquidTemperature(roomTemp: roomTemp, kneadingHeating: kneadingHeating, databaseReader: databaseReader)) ?? roomTemp
        }
    }
    
    func flourMass(for stepId: Int64) -> Double {
        findStepAndReturnAttribute(for: stepId, failValue: 0) { step in
            step.flourMass(reader: databaseReader)
        }
    }
    
    func waterMass(for stepId: Int64) -> Double {
        findStepAndReturnAttribute(for: stepId, failValue: 0) { step in
            step.waterMass(reader: databaseReader)
        }
    }
    
}
