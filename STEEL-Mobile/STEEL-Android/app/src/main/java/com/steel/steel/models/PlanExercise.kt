package com.steel.steel.models

import kotlinx.serialization.Serializable

/**
 * Plan Exercise model - Exercises within plan days
 */
@Serializable
data class PlanExercise(
    val id: String,
    val planDay: String,
    val exercise: String? = null,
    val name: String? = null,
    val order: Int? = null,
    val sets: Int? = null,
    val repsMin: Int? = null,
    val repsMax: Int? = null,
    val rpeTarget: Double? = null,
    val restSeconds: Int? = null,
    val notes: String? = null,
    val substitutions: Map<String, Any>? = null,
    val created: String,
    val updated: String
)