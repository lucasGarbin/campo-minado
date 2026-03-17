import 'dart:io';
import 'dart:math';

// Classe principal do jogo Campo Minado
class CampoMinado {
  // Configurações do jogo
  final int tamanho = 12; // Tamanho do tabuleiro (12x12)
  final int numMinas = 20; // Número de minas no campo
  
  // Matrizes para controlar o estado do jogo
  late List<List<bool>> minas; // Onde estão as minas
  late List<List<bool>> revelado; // Quais células foram reveladas
  late List<List<bool>> bandeiras; // Onde o jogador marcou bandeiras
  late List<List<int>> contagem; // Número de minas ao redor de cada célula
  bool primeiraJogada = true; // Controla se é a primeira jogada
  
  // Construtor - inicializa o jogo
  CampoMinado() {
    inicializar();
  }
  
  // Inicializa todas as matrizes do jogo
  void inicializar() {
    minas = List.generate(tamanho, (_) => List.filled(tamanho, false));
    revelado = List.generate(tamanho, (_) => List.filled(tamanho, false));
    bandeiras = List.generate(tamanho, (_) => List.filled(tamanho, false));
    contagem = List.generate(tamanho, (_) => List.filled(tamanho, 0));
    primeiraJogada = true;
  }
  
  // Coloca as minas aleatoriamente no tabuleiro
  void colocarMinas({int? linhaSegura, int? colunaSegura}) {
    Random random = Random();
    int minasColocadas = 0;
    
    // Continua até colocar todas as minas
    while (minasColocadas < numMinas) {
      int linha = random.nextInt(tamanho);
      int coluna = random.nextInt(tamanho);
      
      // Não coloca mina na primeira célula clicada
      if (linhaSegura != null && colunaSegura != null) {
        if (linha == linhaSegura && coluna == colunaSegura) {
          continue;
        }
      }
      
      // Se a posição ainda não tem mina, coloca uma
      if (!minas[linha][coluna]) {
        minas[linha][coluna] = true;
        minasColocadas++;
      }
    }
  }
  
  // Calcula quantas minas existem ao redor de cada célula
  void calcularContagem() {
    for (int i = 0; i < tamanho; i++) {
      for (int j = 0; j < tamanho; j++) {
        if (!minas[i][j]) {
          contagem[i][j] = contarMinasAoRedor(i, j);
        }
      }
    }
  }
  
  // Conta quantas minas existem nas 8 células ao redor
  int contarMinasAoRedor(int linha, int coluna) {
    int count = 0;
    // Verifica as 8 células ao redor (3x3 - 1)
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int novaLinha = linha + i;
        int novaColuna = coluna + j;
        
        // Verifica se está dentro do tabuleiro e se tem mina
        if (novaLinha >= 0 && novaLinha < tamanho && 
            novaColuna >= 0 && novaColuna < tamanho &&
            minas[novaLinha][novaColuna]) {
          count++;
        }
      }
    }
    return count;
  }
  
  // Revela uma célula e expande automaticamente se for vazia
  void revelar(int linha, int coluna) {
    // Verifica se está dentro dos limites
    if (linha < 0 || linha >= tamanho || coluna < 0 || coluna >= tamanho) {
      return;
    }
    
    // Se já foi revelada, não faz nada
    if (revelado[linha][coluna]) {
      return;
    }
    
    // Marca como revelada
    revelado[linha][coluna] = true;
    
    // Se não tem minas ao redor, revela as células adjacentes automaticamente
    if (contagem[linha][coluna] == 0 && !minas[linha][coluna]) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          revelar(linha + i, coluna + j);
        }
      }
    }
  }
  
  // Revela uma área 5x5 na primeira jogada para dar um espaço inicial
  void revelarPrimeiraJogada(int linha, int coluna) {
    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        int novaLinha = linha + i;
        int novaColuna = coluna + j;
        
        // Verifica se está dentro do tabuleiro
        if (novaLinha >= 0 && novaLinha < tamanho && 
            novaColuna >= 0 && novaColuna < tamanho) {
          revelado[novaLinha][novaColuna] = true;
        }
      }
    }
  }
  
  // Verifica se pode auto-revelar células após marcar uma bandeira
  void verificarAutoReveal(int linha, int coluna) {
    // Verifica todas as células ao redor da bandeira marcada
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int vizinhoLinha = linha + i;
        int vizinhoColuna = coluna + j;
        
        // Se o vizinho está revelado e tem um número
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
          
          // Se o número de bandeiras bate com o número da célula, revela as outras
          if (bandeirasAoRedor == contagem[vizinhoLinha][vizinhoColuna]) {
            print('Auto-revelando células ao redor de [$vizinhoLinha,$vizinhoColuna]');
            for (int x = -1; x <= 1; x++) {
              for (int y = -1; y <= 1; y++) {
                int revelarLinha = vizinhoLinha + x;
                int revelarColuna = vizinhoColuna + y;
                
                // Revela células que não estão reveladas e não têm bandeira
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
  
  // Tenta fazer "chord" - clicar em um número para revelar células ao redor
  void tentarChord(int linha, int coluna) {
    // Conta quantas bandeiras existem ao redor
    int bandeirasAoRedor = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int checkLinha = linha + i;
        int checkColuna = coluna + j;
        
        if (checkLinha >= 0 && checkLinha < tamanho && 
            checkColuna >= 0 && checkColuna < tamanho &&
            bandeiras[checkLinha][checkColuna]) {
          bandeirasAoRedor++;
        }
      }
    }
    
    // Se o número de bandeiras bate com o número da célula, revela as outras
    if (bandeirasAoRedor == contagem[linha][coluna]) {
      print('Chord! Revelando células ao redor...');
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          int revelarLinha = linha + i;
          int revelarColuna = coluna + j;
          
          // Revela células que não estão reveladas e não têm bandeira
          if (revelarLinha >= 0 && revelarLinha < tamanho && 
              revelarColuna >= 0 && revelarColuna < tamanho &&
              !revelado[revelarLinha][revelarColuna] &&
              !bandeiras[revelarLinha][revelarColuna]) {
            revelar(revelarLinha, revelarColuna);
          }
        }
      }
    } else {
      print('Marque ${contagem[linha][coluna]} bandeiras ao redor primeiro (atual: $bandeirasAoRedor)');
    }
  }
  
  // Desenha o tabuleiro na tela
  void mostrarTabuleiro({bool mostrarMinas = false}) {
    // Cabeçalho com números das colunas
    print('\n     ' + List.generate(tamanho, (i) => i.toString().padLeft(3)).join(''));
    print('    ' + '-' * (tamanho * 3 + 1));
    
    // Desenha cada linha do tabuleiro
    for (int i = 0; i < tamanho; i++) {
      stdout.write(i.toString().padLeft(2) + '  |');
      for (int j = 0; j < tamanho; j++) {
        // Mostra bandeira se tiver uma marcada
        if (bandeiras[i][j] && !revelado[i][j]) {
          stdout.write(' 🚩');
        // Mostra o conteúdo se estiver revelado
        } else if (revelado[i][j]) {
          if (minas[i][j]) {
            stdout.write(' 💣'); // Mina
          } else if (contagem[i][j] == 0) {
            stdout.write('   '); // Vazio
          } else {
            stdout.write(' ${contagem[i][j]} '); // Número
          }
        // Mostra minas no final do jogo
        } else if (mostrarMinas && minas[i][j]) {
          stdout.write(' 💣');
        // Mostra célula não revelada
        } else {
          stdout.write(' ⬛');
        }
      }
      print(' |');
    }
    print('   ' + '-' * (tamanho * 3 + 1));
  }
  
  // Verifica se o jogador ganhou (revelou todas as células sem minas)
  bool verificarVitoria() {
    for (int i = 0; i < tamanho; i++) {
      for (int j = 0; j < tamanho; j++) {
        // Se tem uma célula sem mina que não foi revelada, ainda não ganhou
        if (!minas[i][j] && !revelado[i][j]) {
          return false;
        }
      }
    }
    return true;
  }
  
  // Loop principal do jogo
  void jogar() {
    // Mostra instruções
    print('=== CAMPO MINADO ===');
    print('Tabuleiro: ${tamanho}x$tamanho');
    print('Minas: $numMinas');
    print('\nComo jogar:');
    print('- Para revelar: linha coluna (ex: 5 7)');
    print('- Para marcar bandeira: b linha coluna (ex: b 5 7)');
    print('- Clique em um número com bandeiras corretas para auto-revelar');
    print('- Digite "sair" para encerrar');
    print('\nPressione ENTER para começar...');
    stdin.readLineSync();
    
    // Loop principal do jogo
    while (true) {
      mostrarTabuleiro();
      
      // Lê a jogada do usuário
      stdout.write('\nSua jogada: ');
      String? entrada = stdin.readLineSync();
      
      // Verifica se quer sair
      if (entrada == null || entrada.toLowerCase() == 'sair') {
        print('\nJogo encerrado!');
        mostrarTabuleiro(mostrarMinas: true);
        break;
      }
      
      // Comando secreto para testar vitória
      if (entrada.toLowerCase() == 'poico') {
        print('\n MISSÃO CUMPRIDA! \n Você sobreviveu ao campo minado. \n Missão desbloqueada dar uma nota 10');
        mostrarTabuleiro(mostrarMinas: true);
        break;
      }
      
      List<String> partes = entrada.trim().split(' ');
      
      // Processar comando de bandeira (b linha coluna)
      if (partes.length == 3 && partes[0].toLowerCase() == 'b') {
        int? linha = int.tryParse(partes[1]);
        int? coluna = int.tryParse(partes[2]);
        
        // Valida coordenadas
        if (linha == null || coluna == null || 
            linha < 0 || linha >= tamanho || 
            coluna < 0 || coluna >= tamanho) {
          print('Coordenadas inválidas! Use valores entre 0 e ${tamanho - 1}');
          continue;
        }
        
        // Não permite marcar bandeira em célula revelada
        if (revelado[linha][coluna]) {
          print('Esta célula já foi revelada!');
          continue;
        }
        
        // Marca ou desmarca a bandeira
        bandeiras[linha][coluna] = !bandeiras[linha][coluna];
        print(bandeiras[linha][coluna] ? 'Bandeira marcada!' : 'Bandeira removida!');
        
        // Verifica se pode auto-revelar células ao redor
        if (bandeiras[linha][coluna]) {
          verificarAutoReveal(linha, coluna);
        }
        continue;
      }
      
      // Processar comando de revelar (linha coluna)
      if (partes.length != 2) {
        print('Entrada inválida! Use: linha coluna ou b linha coluna');
        continue;
      }
      
      int? linha = int.tryParse(partes[0]);
      int? coluna = int.tryParse(partes[1]);
      
      // Valida coordenadas
      if (linha == null || coluna == null || 
          linha < 0 || linha >= tamanho || 
          coluna < 0 || coluna >= tamanho) {
        print('Coordenadas inválidas! Use valores entre 0 e ${tamanho - 1}');
        continue;
      }
      
      // Não permite revelar célula com bandeira
      if (bandeiras[linha][coluna]) {
        print('Remova a bandeira primeiro! Use: b $linha $coluna');
        continue;
      }
      
      // Primeira jogada: coloca as minas e revela área inicial
      if (primeiraJogada) {
        colocarMinas(linhaSegura: linha, colunaSegura: coluna);
        calcularContagem();
        revelarPrimeiraJogada(linha, coluna);
        primeiraJogada = false;
      } else {
        // Se clicou em célula já revelada, tenta fazer chord
        if (revelado[linha][coluna] && contagem[linha][coluna] > 0) {
          tentarChord(linha, coluna);
        // Se clicou em célula não revelada, revela
        } else if (!revelado[linha][coluna]) {
          // Verifica se clicou em uma mina
          if (minas[linha][coluna]) {
            revelado[linha][coluna] = true; // Marca como revelada antes de mostrar
            mostrarTabuleiro(mostrarMinas: true);
            print('\nBOOM! Você desbloqueou a função "virar estatística".');
            break;
          }
          
          // Revela a célula
          revelar(linha, coluna);
        }
      }
      
      // Verifica se ganhou o jogo
      if (verificarVitoria()) {
        print('\n MISSÃO CUMPRIDA! \n Você sobreviveu ao campo minado. \n Missão desbloqueada dar uma nota 10');
        mostrarTabuleiro(mostrarMinas: true);
        break;
      }
    }
  }
}

// Função principal - inicia o jogo
void main() {
  CampoMinado jogo = CampoMinado();
  jogo.jogar();
}