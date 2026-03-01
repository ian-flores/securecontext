#' Generate a new 32-byte encryption key
#'
#' Creates a cryptographically random 32-byte key suitable for AES-256-CBC
#' encryption of vector stores and knowledge stores.
#'
#' @return Raw vector of 32 bytes.
#' @export
new_encryption_key <- function() {
  if (!requireNamespace("openssl", quietly = TRUE)) {
    cli_abort("Package {.pkg openssl} is required for encryption. Install it with {.code install.packages(\"openssl\")}.")
  }
  openssl::rand_bytes(32)
}

#' Encrypt raw data with AES-256-CBC
#'
#' @param data Raw vector to encrypt.
#' @param key Raw 32-byte key.
#' @return Encrypted raw vector (IV prepended).
#' @keywords internal
encrypt_raw <- function(data, key) {
  if (!is.raw(key) || length(key) != 32L) {
    cli_abort("{.arg key} must be a 32-byte raw vector.")
  }
  encrypted <- openssl::aes_cbc_encrypt(data, key)
  iv <- attr(encrypted, "iv")
  c(iv, as.raw(encrypted))
}

#' Decrypt raw data with AES-256-CBC
#'
#' @param data Encrypted raw vector (IV prepended).
#' @param key Raw 32-byte key.
#' @return Decrypted raw vector.
#' @keywords internal
decrypt_raw <- function(data, key) {
  if (!is.raw(key) || length(key) != 32L) {
    cli_abort("{.arg key} must be a 32-byte raw vector.")
  }
  iv <- data[1:16]
  ciphertext <- data[17:length(data)]
  openssl::aes_cbc_decrypt(ciphertext, key, iv = iv)
}

#' Resolve encryption key from parameter or environment
#'
#' Checks for an explicit key first, then falls back to the
#' `SECURECONTEXT_ENCRYPTION_KEY` environment variable (hex-encoded).
#'
#' @param key Raw key, or `NULL` to check env var.
#' @return Raw 32-byte key, or `NULL` if no encryption configured.
#' @keywords internal
resolve_encryption_key <- function(key = NULL) {
  if (!is.null(key)) {
    if (!is.raw(key) || length(key) != 32L) {
      cli_abort("{.arg key} must be a 32-byte raw vector.")
    }
    return(key)
  }
  env_key <- Sys.getenv("SECURECONTEXT_ENCRYPTION_KEY", "")
  if (nzchar(env_key)) {
    key_raw <- as.raw(strtoi(substring(env_key, seq(1, 63, 2), seq(2, 64, 2)), 16L))
    if (length(key_raw) != 32L) {
      cli_abort("SECURECONTEXT_ENCRYPTION_KEY must be a 64-character hex string (32 bytes).")
    }
    return(key_raw)
  }
  NULL
}
