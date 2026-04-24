import java.util.HashMap;
import java.io.File;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.FileReader;

public class TestProgram {
    static int passed = 0;
    static int failed = 0;

    public static void main(String[] args) {
        // Test 1: Basic output
        System.out.println("Hello from Hummingbird OpenJDK 25!");
        passed++;
        System.out.println("  Basic Output - PASSED");

        // Test 2: HashMap operations
        try {
            HashMap<String, Object> data = new HashMap<>();
            data.put("name", "test");
            data.put("value", 123);
            if ("test".equals(data.get("name")) && Integer.valueOf(123).equals(data.get("value"))) {
                System.out.println("  HashMap Operations - PASSED");
                passed++;
            } else {
                System.out.println("  HashMap Operations - FAILED");
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  HashMap Operations - FAILED: " + e.getMessage());
            failed++;
        }

        // Test 3: String processing
        String text = "hummingbird java test";
        if (text.toUpperCase().equals("HUMMINGBIRD JAVA TEST")) {
            System.out.println("  String Processing - PASSED");
            passed++;
        } else {
            System.out.println("  String Processing - FAILED");
            failed++;
        }

        // Test 4: File operations
        try {
            File tmpFile = new File("/tmp/java-test-file.txt");
            FileWriter writer = new FileWriter(tmpFile);
            writer.write("test content\n");
            writer.close();

            BufferedReader reader = new BufferedReader(new FileReader(tmpFile));
            String content = reader.readLine();
            reader.close();
            tmpFile.delete();

            if ("test content".equals(content)) {
                System.out.println("  File Operations - PASSED");
                passed++;
            } else {
                System.out.println("  File Operations - FAILED: got " + content);
                failed++;
            }
        } catch (Exception e) {
            System.out.println("  File Operations - FAILED: " + e.getMessage());
            failed++;
        }

        System.out.println("\nResults: " + passed + " passed, " + failed + " failed");
        if (failed > 0) System.exit(1);
    }
}
