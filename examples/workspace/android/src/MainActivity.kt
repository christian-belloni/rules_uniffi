package com.example.app

import uniffi.my_artifact.multiplyArtifact;

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.material.Text

class MainActivity : AppCompatActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val multiplied = multiplyArtifact(2, 5)
    val otherMultiplied = uniffi.my_multiplier.multiply(3, 7)
    setContent {
      Text(text = "Hello $multiplied $otherMultiplied")
    }
  }
}
