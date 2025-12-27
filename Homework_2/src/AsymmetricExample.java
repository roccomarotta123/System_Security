import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Security;
import java.security.Signature;
import java.util.Base64;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

public class AsymmetricExample {

    public static void main(String[] args) throws Exception {
        // 1. Add Bouncy Castle Provider
        Security.addProvider(new BouncyCastleProvider());
        System.out.println("--- Asymmetric Cryptography (RSA 2048) ---");

        // 2. Generate RSA Key Pair
        System.out.println("Generating RSA Key Pair (2048 bits)...");
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA", "BC");
        keyGen.initialize(2048, new SecureRandom());
        KeyPair pair = keyGen.generateKeyPair();
        PrivateKey priv = pair.getPrivate();
        PublicKey pub = pair.getPublic();

        System.out.println("Public Key Format: " + pub.getFormat());
        System.out.println("Private Key Format: " + priv.getFormat());

        // 3. Define message to sign
        String message = "This statement is digitally signed by Rocco.";
        System.out.println("\nMessage: " + message);

        // 4. Sign the message
        Signature rsaSign = Signature.getInstance("SHA256withRSA", "BC");
        rsaSign.initSign(priv);
        rsaSign.update(message.getBytes());
        byte[] signature = rsaSign.sign();
        
        System.out.println("\nSignature (Base64):");
        System.out.println(Base64.getEncoder().encodeToString(signature));

        // 5. Verify the signature
        Signature rsaVerify = Signature.getInstance("SHA256withRSA", "BC");
        rsaVerify.initVerify(pub); // Using public key!
        rsaVerify.update(message.getBytes());
        boolean isVerified = rsaVerify.verify(signature);

        System.out.println("\nVerification Result: " + isVerified);

        if (isVerified) {
            System.out.println("[SUCCESS] Signature verified correctly.");
        } else {
            System.err.println("[ERROR] Signature verification failed!");
        }
    }
}
