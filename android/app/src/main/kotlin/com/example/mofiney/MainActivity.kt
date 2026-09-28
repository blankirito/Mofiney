package com.example.mofiney

import android.net.Uri
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val receiptOcrChannel = "mofiney/receipt_ocr"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            receiptOcrChannel,
        ).setMethodCallHandler { call, result ->
            if (call.method != "recognizeReceipt") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val imagePath = call.argument<String>("imagePath")

            if (imagePath.isNullOrBlank()) {
                result.error(
                    "invalid_image_path",
                    "A receipt image path is required.",
                    null,
                )
                return@setMethodCallHandler
            }

            val imageFile = File(imagePath)

            if (!imageFile.exists()) {
                result.error(
                    "image_not_found",
                    "The receipt image could not be found.",
                    null,
                )
                return@setMethodCallHandler
            }

            val image = try {
                InputImage.fromFilePath(this, Uri.fromFile(imageFile))
            } catch (error: Exception) {
                result.error(
                    "invalid_image",
                    error.message ?: "Could not open the receipt image.",
                    null,
                )
                return@setMethodCallHandler
            }

            val latinRecognizer = TextRecognition.getClient(
                TextRecognizerOptions.DEFAULT_OPTIONS,
            )

            val chineseRecognizer = TextRecognition.getClient(
                ChineseTextRecognizerOptions.Builder().build(),
            )

            latinRecognizer.process(image)
                .addOnSuccessListener { latinResult ->
                    chineseRecognizer.process(image)
                        .addOnSuccessListener { chineseResult ->
                            result.success(
                                mapOf(
                                    "latinText" to latinResult.text,
                                    "chineseText" to chineseResult.text,
                                ),
                            )

                            latinRecognizer.close()
                            chineseRecognizer.close()
                        }
                        .addOnFailureListener { error ->
                            latinRecognizer.close()
                            chineseRecognizer.close()

                            result.error(
                                "receipt_ocr_failed",
                                error.message ?: "Could not read the receipt.",
                                null,
                            )
                        }
                }
                .addOnFailureListener { error ->
                    latinRecognizer.close()
                    chineseRecognizer.close()

                    result.error(
                        "receipt_ocr_failed",
                        error.message ?: "Could not read the receipt.",
                        null,
                    )
                }
        }
    }
}