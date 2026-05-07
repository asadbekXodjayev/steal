package com.steel.steel.models

import kotlinx.serialization.Serializable

/**
 * Session Set model - Individual set data
 */
@Serializable
data class SessionSet(
    val id: String,
    val session: String,
    val exercise: String? = null,
    val setNumber: Int? = null,
    val reps: Int? = null,
    val weight: Double? = null,
    val rpe: Double? = null,
    val completed: Boolean = false,
    val notes: String? = null,
    val created: String,
    val updated: String
)