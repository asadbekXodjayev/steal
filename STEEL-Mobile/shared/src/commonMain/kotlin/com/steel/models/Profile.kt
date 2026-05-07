package com.steel.models

import kotlinx.serialization.Serializable

/**
 * Profile model - User profile data
 */
@Serializable
data class Profile(
    val id: String,
    val user: String,
    val age: Int? = null,
    val height: Int? = null,      // cm
    val weight: Double? = null,   // kg
    val gender: Gender? = null,
    val fitnessLevel: FitnessLevel? = null,
    val limitations: List<String>? = null,
    val injuryHistory: String? = null,
    val onboardingComplete: Boolean = false,
    val created: String,
    val updated: String
)

@Serializable
enum class Gender {
    male, female, other, prefer_not_to_say
}

@Serializable
enum class FitnessLevel {
    beginner, intermediate, advanced
}