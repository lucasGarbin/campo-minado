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
  
  int contarMinasAoRedor(int linha, int coluna) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int novaLinha = linha + i;
        int novaColuna = coluna + j;
        
        if (novaLinha >= 0 && novaLinha < tamanho && 
            novaColuna >= 0 && novaColuna < tamanho &&
            minas[novaLinha][novaColuna]) {
          count++;
        }
      }
    }
    return count;
  }
  
  void revelar(int linha, int coluna) {
    if (linha < 0 || linha >= tamanho || coluna < 0 || coluna >= tamanho) {
      return;
    }
    
    if (revelado[linha][coluna]) {
      return;
    }
    
    revelado[linha][coluna] = true;
    
    if (contagem[linha][coluna] == 0 && !minas[linha][coluna]) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          revelar(linha + i, coluna + j);
        }
      }
    }
  }
  
  void revelarPrimeiraJogada(int linha, int coluna) {
    // Revela uma área 5x5 centrada no clique inicial
    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        int novaLinha = linha + i;
        int novaColuna = coluna + j;
        
        if (novaLinha >= 0 && novaLinha < tamanho && 
            novaColuna >= 0 && novaColuna < tamanho) {
          revelado[novaLinha][novaColuna] = true;
        }
      }
    }
  }
  
  void verificarAutoReveal(int linha, int coluna) {
    // Verifica todas as células ao redor da bandeira marcada
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int vizinhoLinha = linha + i;
        int vizinhoColuna = coluna + j;
        
        if (vizinhoLinha >= 0 && vizinhoLinha < tamanho && 
            vizinhoColuna >= 0 && vizinhoColuna < tamanho &&
            revelado[vizinhoLinha][vizinhoColuna] &&
            contagem[vizinhoLinha][vizinhoColuna] > 0) {
          
          // Conta quantas bandeiras existem ao redor desta célula
          int bandeirasAoRedor = 0;
          for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
              int checkLinha = vizinhoLinha + x;
              int checkColuna = vizinhoColuna + y;
              
              if (checkLinha >= 0 && checkLinha < tamanho && 
                  checkColuna >= 0 && checkColuna < tamanho &&
                  bandeiras[checkLinha][checkColuna]) {
                bandeirasAoRedor++;
              }
            }
          }
          
          // Se o número de bandeiras é igual ao número da célula, revela as outras
          if (bandeirasAoRedor == contagem[vizinhoLinha][vizinhoColuna]) {
            print('Auto-revelando células ao redor de [$vizinhoLinha,$vizinhoColuna]');
            for (int x = -1; x <= 1; x++) {
              for (int y = -1; y <= 1; y++) {
                int revelarLinha = vizinhoLinha + x;
                int revelarColuna = vizinhoColuna + y;
                
                if (revelarLinha >= 0 && revelarLinha < tamanho && 
                    revelarColuna >= 0 && revelarColuna < tamanho &&
                    !revelado[revelarLinha][revelarColuna] &&
                    !bandeiras[revelarLinha][revelarColuna]) {
                  revelar(revelarLinha, revelarColuna);
                }
              }
            }
          }
        }
      }
    }
  }