// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later
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
    
    /// steps which have ingredients or substeps for a given recipe minust the current stepId and the ones that are already a substep of the current step
    func stepsWithIngredientsOrSupersteps(in recipeId: Int64, without stepId: Int64) -> [Step] {
        
        return (try? databaseReader.read { db in
            try Step.fetchAll(db, sql: """
                SELECT DISTINCT Step.*
                FROM Step
                LEFT JOIN Ingredient ON Ingredient.stepId = Step.id
                LEFT JOIN Step AS sub ON sub.superStepId = Step.id
                WHERE Step.recipeId = ?
                  AND Step.id != ?
                  AND Step.id NOT IN (SELECT id FROM Step WHERE superStepId = ?)
                  AND (Ingredient.id IS NOT NULL OR sub.id IS NOT NULL)
                """, arguments: [recipeId, stepId, stepId])
        }) ?? []
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
