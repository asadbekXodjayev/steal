package com.steel.models

import kotlinx.serialization.Serializable

/**
 * User model - PocketBase auth collection
 */
@Serializable
data class User(
    val id: String,
    val email: String,
    val name: String? = null,
    val avatar: String? = null,
    val created: String,
    val updated: String,
    
    // Auth-specific fields
    val emailVisibility: Boolean = false,
    val verified: Boolean = false
)