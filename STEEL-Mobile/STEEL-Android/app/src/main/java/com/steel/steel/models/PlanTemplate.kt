package com.steel.steel.models

import kotlinx.serialization.Serializable

/**
 * Plan Template model - Pre-made plan templates
 */
@Serializable
data class PlanTemplate(
    val id: String,
    val title: String,
    val description: String? = null,
    val goalType: GoalType? = null,
    val environment: Environment? = null,
    val difficulty: ExerciseDifficulty? = null,
    val durationWeeks: Int? = null,
    val structure: Map<String, Any>? = null,
    val popularity: Int? = null,
    val created: String,
    val updated: String
)