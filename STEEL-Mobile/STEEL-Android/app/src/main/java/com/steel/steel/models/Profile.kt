package com.steel.steel.models

import kotlinx.serialization.Serializable

/**
 * Exercise Translation model - Exercise name translations
 */
@Serializable
data class ExerciseTranslation(
    val id: String,
    val exercise: String,
    val locale: String,
    val name: String,
    val instructions: String? = null,
    val created: String,
    val updated: String
)