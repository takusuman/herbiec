# herbiec

|[![](https://github.com/takusuman/herbiec/assets/47103338/9a476483-7395-4c96-ac1a-eb19d5f5f98e)](https://www.dreamstime.com/ragon-beetle-sanpellegrino-terme-yellow-volkswagen-beetle-cabriolet-big-dragon-painted-parked-sanpellegrino-image245116237)|
|:--:|
| *Fusca amarelo com uma grande pintura de dragão no evento [Bèrghem Bug](https://www.facebook.com/berghem.bug), ocorrido em 2020 na comuna de San Pellegrino Terme, na Itália. Foto por [Raffaele Mottalini](http://www.mastroraf.it), via [Dreamstime](https://www.dreamstime.com/ragon-beetle-sanpellegrino-terme-yellow-volkswagen-beetle-cabriolet-big-dragon-painted-parked-sanpellegrino-image245116237).* |

[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg)](https://opensource.org/licenses/ISC)
[![Powered By Copacabana @ Docker](http://copacabana.pindorama.dob.jp/assets/styles/img/COPACABANA/badges/256.102x46/COPACABANA_x64-256.102x46.PNG)](https://hub.docker.com/r/takusuman/copadocker)

## Introdução

O herbiec é um interpretador do tipo *tree-walking* feito especificamente para a
[Rinha de Compiladores](https://github.com/aripiprazole/rinha-de-compiler/)
desse ano, organizada pela Sofia Rodrigues e pela Gabrielle Guimarães.  
Por mais que o programa (ou script, chame-o como preferir) não tenha muito
propósito fora do desafio enquanto interpretador, alguns usos de funções da
linguagem aqui se mostraram interessantes para se replicar posteriormente como,
por exemplo, uma função para
[conversão de JSON para uma estrutura de variável composta](https://github.com/takusuman/herbiec/blob/master/herbiec.ksh#L284)
e métodos para poder receber [elementos de variáveis compostas como entrada de
função](https://github.com/takusuman/herbiec/blob/master/herbiec.ksh#L223-L256),
algo que é pouco usado na linguagem mesmo estando ali desde a criação do padrão.
Creio que servirá bem para questão de aprendizado.

## Bugs descobertos

Graças à minha brilhante ideia de fazer um interpretador em Korn Shell 93 ---
mesmo que a linguagem tenha se mostraddo mais-do-que capaz de fazer ---, acabei
por descobrir alguns bugs no processo, tanto na hora de programar quanto na hora
de testar.

- No dia 22 de Setembro de 2023, enquanto testava o algoritmo da soma de Gauss,
  descobri um bug que causa um "Memory fault" (lit. "Falha de memória") quando
  tenta se somar até 1 milhão, o que foi reportado à equipe de desenvolvimento
  do KornShell 93 na [*issue* #686](https://github.com/ksh93/ksh/issues/686).
- O KornShell 93, na versão 1.0.0-beta.2, lançada em 17 de Dezembro de 2021, não
  suporta variáveis com identificadores UTF-8, como, por exemplo,
  ``float φ=$(( (1 + sqrt(5)) / 2 ))`` --- entretanto, isso funciona perfeitamente
  nas versões mais recentes, então não reportei.
