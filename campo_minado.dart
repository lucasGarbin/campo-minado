import 'dart:io';
import 'dart:math';

class CampoMinado {
  final int tamanho = 12;
  final int numMinas = 20;
  late List<List<bool>> minas;
  late List<List<bool>> revelado;
  late List<List<bool>> bandeiras;
  late List<List<int>> contagem;
  bool primeiraJogada = true;
  
  CampoMinado() {
    inicializar();
  }
  
  void inicializar() {
    minas = List.generate(tamanho, (_) => List.filled(tamanho, false));
    revelado = List.generate(tamanho, (_) => List.filled(tamanho, false));
    bandeiras = List.generate(tamanho, (_) => List.filled(tamanho, false));
    contagem = List.generate(tamanho, (_) => List.filled(tamanho, 0));
    primeiraJogada = true;
  }
  
  void colocarMinas({int? linhaSegura, int? colunaSegura}) {
    Random random = Random();
    int minasColocadas = 0;
    
    while (minasColocadas < numMinas) {
      int linha = random.nextInt(tamanho);
      int coluna = random.nextInt(tamanho);
      
      // Não colocar mina apenas na célula clicada
      if (linhaSegura != null && colunaSegura != null) {
        if (linha == linhaSegura && coluna == colunaSegura) {
          continue;
        }
      }
      
      if (!minas[linha][coluna]) {
        minas[linha][coluna] = true;
        minasColocadas++;
      }
    }
  }
  
  void calcularContagem() {
    for (int i = 0; i < tamanho; i++) {
      for (int j = 0; j < tamanho; j++) {
        if (!minas[i][j]) {
          contagem[i][j] = contarMinasAoRedor(i, j);
        }
      }
    }
  }