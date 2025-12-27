import java.io.FileInputStream;
import java.security.Security;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Collections;
import org.bouncycastle.jce.provider.BouncyCastleProvider;

public class CertificateAnalyzer {

    public static void main(String[] args) throws Exception {
        Security.addProvider(new BouncyCastleProvider());
        System.out.println("--- Certificate Analysis Demo ---");

        // 1. Load Certificates
        X509Certificate rootCert = loadCert("root_ca.crt");
        X509Certificate userCert = loadCert("user.crt");

        // 2. Analyze User Certificate
        System.out.println("\n[Analysis] User Certificate:");
        System.out.println("  Subject DN: " + userCert.getSubjectX500Principal());
        System.out.println("  Issuer DN : " + userCert.getIssuerX500Principal());
        System.out.println("  Serial No : " + userCert.getSerialNumber());
        System.out.println("  Not Before: " + userCert.getNotBefore());
        System.out.println("  Not After : " + userCert.getNotAfter());
        System.out.println("  Sig Algo  : " + userCert.getSigAlgName());

        // 3. Analyze Extensions (KeyUsage)
        boolean[] keyUsage = userCert.getKeyUsage();
        if (keyUsage != null) {
            System.out.print("  Key Usage : ");
            if (keyUsage[0]) System.out.print("DigitalSignature ");
            if (keyUsage[1]) System.out.print("NonRepudiation ");
            if (keyUsage[2]) System.out.print("KeyEncipherment ");
            if (keyUsage[3]) System.out.print("DataEncipherment ");
            if (keyUsage[4]) System.out.print("KeyAgreement ");
            if (keyUsage[5]) System.out.print("KeyCertSign ");
            if (keyUsage[6]) System.out.print("CRLSign ");
            System.out.println();
        }

        // 4. Verify Chain
        System.out.println("\n[Verification] Chain of Trust:");
        try {
            userCert.verify(rootCert.getPublicKey());
            System.out.println("  [PASS] User Certificate IS signed by Root CA.");
        } catch (Exception e) {
            System.err.println("  [FAIL] User Certificate verification failed: " + e.getMessage());
        }

        System.out.println("\n[Verification] Root Self-Check:");
        try {
            rootCert.verify(rootCert.getPublicKey());
            System.out.println("  [PASS] Root CA is correctly Self-Signed.");
        } catch (Exception e) {
            System.err.println("  [FAIL] Root CA self-verification failed: " + e.getMessage());
        }
    }

    private static X509Certificate loadCert(String filename) throws Exception {
        CertificateFactory fact = CertificateFactory.getInstance("X.509", "BC");
        try (FileInputStream fis = new FileInputStream(filename)) {
            return (X509Certificate) fact.generateCertificate(fis);
        }
    }
}
