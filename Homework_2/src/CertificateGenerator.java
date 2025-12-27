import java.io.FileWriter;
import java.io.IOException;
import java.math.BigInteger;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Security;
import java.security.cert.X509Certificate;
import java.util.Date;
import java.util.Calendar;

import org.bouncycastle.asn1.x500.X500Name;
import org.bouncycastle.asn1.x509.BasicConstraints;
import org.bouncycastle.asn1.x509.Extension;
import org.bouncycastle.asn1.x509.KeyUsage;
import org.bouncycastle.cert.X509CertificateHolder;
import org.bouncycastle.cert.X509v3CertificateBuilder;
import org.bouncycastle.cert.jcajce.JcaX509CertificateConverter;
import org.bouncycastle.cert.jcajce.JcaX509v3CertificateBuilder;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.operator.ContentSigner;
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder;
import org.bouncycastle.openssl.jcajce.JcaPEMWriter;

public class CertificateGenerator {

    public static void main(String[] args) throws Exception {
        Security.addProvider(new BouncyCastleProvider());
        System.out.println("--- Certificate Authority & Chain Demo ---");

        // 1. Generate Root CA
        System.out.println("[1] Generating Root CA KeyPair (4096 bit)...");
        KeyPair rootPair = generateKeyPair(4096);
        
        System.out.println("[2] Generating Root CA Certificate (Self-Signed)...");
        X509Certificate rootCert = generateReferenceCert(
            rootPair, 
            "CN=MyJcaRootCA, O=SystemSecurity, C=IT", 
            "CN=MyJcaRootCA, O=SystemSecurity, C=IT", 
            rootPair.getPublic(),
            true // isCA = true
        );
        savePem("root_ca.crt", rootCert);
        savePem("root_ca.key", rootPair.getPrivate());
        System.out.println(" >> Saved: root_ca.crt / root_ca.key");

        // 2. Generate User
        System.out.println("\n[3] Generating User KeyPair (2048 bit)...");
        KeyPair userPair = generateKeyPair(2048);

        System.out.println("[4] Issuing User Certificate (Standard)...");
        X509Certificate userCert = generateReferenceCert(
            rootPair, // Signed by Root Key
            "CN=MyJcaRootCA, O=SystemSecurity, C=IT", // Issuer Name
            "CN=JcaUser, OU=Dev, O=SystemSecurity, C=IT", // Subject Name
            userPair.getPublic(), // User Public Key
            false // isCA = false
        );
        savePem("user.crt", userCert);
        savePem("user.key", userPair.getPrivate());
        System.out.println(" >> Saved: user.crt / user.key");
    }

    private static KeyPair generateKeyPair(int bits) throws Exception {
        KeyPairGenerator kpGen = KeyPairGenerator.getInstance("RSA", "BC");
        kpGen.initialize(bits, new SecureRandom());
        return kpGen.generateKeyPair();
    }

    private static X509Certificate generateReferenceCert(KeyPair signerPair, String issuerDN, String subjectDN, PublicKey publicKey, boolean isCA) throws Exception {
        X500Name issuerName = new X500Name(issuerDN);
        X500Name subjectName = new X500Name(subjectDN);
        BigInteger serial = BigInteger.valueOf(System.currentTimeMillis());
        
        Calendar cal = Calendar.getInstance();
        Date notBefore = cal.getTime();
        cal.add(Calendar.YEAR, 1);
        Date notAfter = cal.getTime();

        JcaX509v3CertificateBuilder builder = new JcaX509v3CertificateBuilder(
            issuerName, serial, notBefore, notAfter, subjectName, publicKey
        );

        // Add Extensions
        builder.addExtension(Extension.basicConstraints, true, new BasicConstraints(isCA));
        
        if (isCA) {
            builder.addExtension(Extension.keyUsage, true, new KeyUsage(KeyUsage.keyCertSign | KeyUsage.cRLSign));
        } else {
            builder.addExtension(Extension.keyUsage, true, new KeyUsage(KeyUsage.digitalSignature | KeyUsage.keyEncipherment));
        }

        // Sign
        ContentSigner signer = new JcaContentSignerBuilder("SHA256withRSA").setProvider("BC").build(signerPair.getPrivate());
        X509CertificateHolder holder = builder.build(signer);

        return new JcaX509CertificateConverter().setProvider("BC").getCertificate(holder);
    }

    private static void savePem(String filename, Object object) throws IOException {
        try (JcaPEMWriter writer = new JcaPEMWriter(new FileWriter(filename))) {
            writer.writeObject(object);
        }
    }
}
