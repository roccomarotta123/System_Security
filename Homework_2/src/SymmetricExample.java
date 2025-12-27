import java.security.Security;
import java.security.SecureRandom;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import java.util.Base64;

public class SymmetricExample {

    public static void main(String[] args) throws Exception {
        // 1. Add Bouncy Castle Provider
        Security.addProvider(new BouncyCastleProvider());
        System.out.println("--- Symmetric Cryptography (AES-256-CBC) ---");

        String plainText = "Hello, System Security! This is a confidential message.";
        System.out.println("Original: " + plainText);

        // 2. Generate Key (256 bit) and IV (16 bytes)
        SecureRandom random = new SecureRandom();
        byte[] keyBytes = new byte[32]; // 256 bits
        random.nextBytes(keyBytes);
        SecretKey key = new SecretKeySpec(keyBytes, "AES");

        byte[] ivBytes = new byte[16]; // AES block size
        random.nextBytes(ivBytes);
        IvParameterSpec iv = new IvParameterSpec(ivBytes);

        System.out.println("Key (Hex): " + bytesToHex(keyBytes));
        System.out.println("IV  (Hex): " + bytesToHex(ivBytes));

        // 3. Encrypt
        Cipher encryptCipher = Cipher.getInstance("AES/CBC/PKCS5Padding", "BC");
        encryptCipher.init(Cipher.ENCRYPT_MODE, key, iv);
        byte[] encryptedBytes = encryptCipher.doFinal(plainText.getBytes());
        String encryptedBase64 = Base64.getEncoder().encodeToString(encryptedBytes);
        System.out.println("Encrypted (Base64): " + encryptedBase64);

        // 4. Decrypt
        Cipher decryptCipher = Cipher.getInstance("AES/CBC/PKCS5Padding", "BC");
        decryptCipher.init(Cipher.DECRYPT_MODE, key, iv);
        byte[] decryptedBytes = decryptCipher.doFinal(Base64.getDecoder().decode(encryptedBase64));
        String decryptedText = new String(decryptedBytes);
        System.out.println("Decrypted: " + decryptedText);
        
        if (plainText.equals(decryptedText)) {
            System.out.println("[SUCCESS] Decryption matches original text.");
        } else {
            System.err.println("[ERROR] Decryption mismatch!");
        }
    }

    // Helper to print bytes as Hex
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}
