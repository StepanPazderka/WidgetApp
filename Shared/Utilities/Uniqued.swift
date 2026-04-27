//
//  Uniqued.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 02.07.2024.
//

import Foundation

extension Sequence {
	/// Returns an array with the unique elements of this sequence (as determined
	/// by the given projection), in the order of the first occurrence of each
	/// unique element.
	///
	/// This example finds the elements of the `animals` array with unique
	/// first characters:
	///
	///     let animals = ["dog", "pig", "cat", "ox", "cow", "owl"]
	///     let uniqued = animals.uniqued(on: { $0.first })
	///     print(uniqued)
	///     // Prints '["dog", "pig", "cat", "ox"]'
	///
	/// - Parameter projection: A closure that transforms an element into the
	///   value to use for uniqueness. If `projection` returns the same value for
	///   two different elements, the second element will be excluded from the
	///   resulting array.
	///
	/// - Returns: An array with only the unique elements of this sequence, as
	///   determined by the result of `projection` for each element.
	///
	/// - Complexity: O(*n*), where *n* is the length of the sequence.
	@inlinable
	public func uniqued<Subject: Hashable>(
		on projection: (Element) throws -> Subject
	) rethrows -> [Element] {
		var seen: Set<Subject> = []
		var result: [Element] = []
		for element in self {
			if seen.insert(try projection(element)).inserted {
				result.append(element)
			}
		}
		return result
	}
}
