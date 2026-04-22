import java.util.Scanner;
import java.util.BitSet;
import java.util.stream.IntStream;

public class benchmark_java {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.println(">>> CALCULADORA DE PRIMOS (ATKIN) <<<");
        System.out.println("Digite o valor limite:");
        long limite = sc.nextLong();

        System.out.println("--- Iniciando Crivo de Atkin ---");
        System.out.println("Limite: " + limite);

        long t1 = System.nanoTime();

        BitSet ehPrimo = new BitSet((int) limite + 1);
        int raiz = (int) Math.sqrt(limite);

        IntStream.rangeClosed(1, raiz).parallel().forEach(x -> {
            long x2 = (long) x * x;
            for (long y = 1; y <= raiz; y++) {
                long y2 = y * y;

                long n = 4 * x2 + y2;
                if (n <= limite && (n % 12 == 1 || n % 12 == 5)) {
                    synchronized (ehPrimo) { ehPrimo.flip((int) n); }
                }

                n = 3 * x2 + y2;
                if (n <= limite && n % 12 == 7) {
                    synchronized (ehPrimo) { ehPrimo.flip((int) n); }
                }

                n = 3 * x2 - y2;
                if (x > y && n <= limite && n % 12 == 11) {
                    synchronized (ehPrimo) { ehPrimo.flip((int) n); }
                }
            }
        });

        for (int s = 5; s <= raiz; s++) {
            if (ehPrimo.get(s)) {
                long s2 = (long) s * s;
                for (long n = s2; n <= limite; n += s2) {
                    ehPrimo.clear((int) n);
                }
            }
        }

        if (limite >= 2) ehPrimo.set(2);
        if (limite >= 3) ehPrimo.set(3);

        long t2 = System.nanoTime();
        double tempoSegundos = (t2 - t1) / 1_000_000_000.0;

        System.out.printf("Tempo total de CPU: %.4f segundos%n", tempoSegundos);
        System.out.println("Primos encontrados: " + ehPrimo.cardinality());
        
        System.out.println("\nPressione ENTER para sair...");
        try { System.in.read(); } catch (Exception e) {}
        
        sc.close();
    }
}