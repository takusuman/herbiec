# herbiec

|[![](https://github.com/takusuman/herbiec/assets/47103338/9a476483-7395-4c96-ac1a-eb19d5f5f98e)](https://www.dreamstime.com/ragon-beetle-sanpellegrino-terme-yellow-volkswagen-beetle-cabriolet-big-dragon-painted-parked-sanpellegrino-image245116237)|
|:--:|
| *Fusca amarelo com uma grande pintura de dragão no evento [Bèrghem Bug](https://www.facebook.com/berghem.bug), ocorrido em 2020 na comuna de San Pellegrino Terme, na Itália. Foto por [Raffaele Mottalini](http://www.mastroraf.it), via [Dreamstime](https://www.dreamstime.com/ragon-beetle-sanpellegrino-terme-yellow-volkswagen-beetle-cabriolet-big-dragon-painted-parked-sanpellegrino-image245116237).* |

[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg)](https://opensource.org/licenses/ISC)
[![Powered By Copacabana @ Docker](http://copacabana.pindorama.dob.jp/assets/styles/img/COPACABANA/badges/256.102x46/COPACABANA_x64-256.102x46.PNG)](https://hub.docker.com/r/takusuman/copadocker)

## Introdução

O herbiec é um interpretador do tipo *tree-walking* feito especificamente para a
[Rinha de Compiladores](https://github.com/aripiprazole/rinha-de-compiler/)
desse ano, organizada pelas srtas. Sofia Rodrigues e Gabrielle Guimarães.  
Por mais que o programa (ou script, chame-o como preferir) não tenha muito
propósito fora do desafio enquanto interpretador propriamente dito, alguns usos de
funções da linguagem aqui se mostraram interessantes para replicar posteriormente como,
por exemplo, uma função para [conversão de JSON para uma estrutura de variável
composta](https://github.com/takusuman/herbiec/blob/master/herbiec.ksh#L375-L408) ---
que precisaria ser melhorada para conseguir lidar com JSONs compactados,
eliminando o a necessidade do [``jq``(1)](https://jqlang.github.io/jq/) como
formatador --- e métodos para poder receber [elementos de variáveis compostas como
entrada de função](https://github.com/takusuman/herbiec/blob/master/herbiec.ksh#L314-L336) ---
o que talvez já existisse de outra forma "oficialmente" e eu desconheça ---,
algo que é pouco explorado na linguagem mesmo estando ali desde a criação do padrão.   
Creio que servirá bem para questão de aprendizado.

### Por que "herbiec"?

Como de costume, normalmente coloco nomes de locais ou referências culturais nos
programas que crio, normal entre todo programador, engenheiro, cientista, artista
ou alquimista.  
"Herbie" em si vem de dois lugares: "Herbie, The Love Bug" (vulgo "Se meu Fusca
falasse"), aquela série de filmes da Disney que creio todos já terem pelo menos
ouvido falar, e do músico instrumentista Herbie Mann, que gravou o álbum
"Memphis Underground" em 1969, ao qual eu estava ouvindo no momento em que testei
o programa pela primeira vez e obtive êxito --- mais especificamente, estava
ouvindo a [faixa 3](https://youtu.be/1hRi_H9KDUc?si=N2gRJUvop6AbJcAv) dele --- e
que é o meu álbum favorito de crossover jazz.


## Bugs descobertos

Graças à minha brilhante ideia de fazer um interpretador em KornShell 93 ---
mesmo que a linguagem tenha se mostrado mais-do-que capaz de fazer ---, acabei
por descobrir alguns bugs no processo, tanto na hora de programar quanto na hora
de testar.

- No dia 22 de Setembro de 2023, enquanto testava o algoritmo da soma de Gauss,
  descobri um bug que causa um "Memory fault" (lit. "Falha de memória") quando
  tenta se somar até 1 milhão, o que foi reportado à equipe de desenvolvimento
  do KornShell 93 na [*issue* #686](https://github.com/ksh93/ksh/issues/686).
  **Atualização**: O @phidebian
  [me respondeu nessa *issue*](https://github.com/ksh93/ksh/issues/686#issuecomment-1738426726)
  mostrando que o erro se dá não pelo tamanho do tipo ``integer`` no KornShell, que
  é de um ``double`` --- ou seja, 9.223.372.036.854.775.807, nove quintilhões, duzentos
  e vinte e três quatrilhões, trezentos e setenta e dois trilhões, trinta e seis bilhões,
  oitocentos e cinquenta e quatro milhões, setecentos e setenta e cinco mil, oitocentos
  e sete, um número ridiculamente grande que faz a soma Gaussiana de 1.000.000 parecer um
  número ínfimo ---, mas sim pelo tamanho da pilha de recursão de
  função de KornShell ser de 1024, fazendo recursão inviável nesse caso.
- O KornShell 93, na versão 1.0.0-beta.2, lançada em 17 de Dezembro de 2021, não
  suporta variáveis com identificadores UTF-8, como, por exemplo,
  ``float φ=$(( (1 + sqrt(5)) / 2 ))`` --- entretanto, isso funciona perfeitamente
  nas versões mais recentes, então não reportei.
