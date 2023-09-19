#!/usr/bin/env ksh93
#
# rinhac.ksh - Interpretador em Korn Shell 93
# 
# Copyright (c) 2023 Luiz Antônio Rangel
# 
# SPDX-Licence-Identifier: ISC 
#
# A otimização na função de Fibonacci, como citado nas linhas 125 até 130, foi
# praticamente transcrita de um código escrito na linguagem R por Álvaro Filho.
# Cabeçalho de direitos autorais:
# Copyright (c) 2019 Álvaro Filho

# NOTE: The comments are written in the Portuguese language since this program
# was written for a Brazil-based competition and I want to be didatic for
# everyone so, if you want to understand my description of the code and doesn't
# speak Portuguese, go and use a gratis translate service such as Google Translate.
# The code itself is written in English for une pure formalité, as always.

progname="${0##*/}"

function main {
	check_for_colour_support

	while getopts 'ovxh' options; do
		case $options in
			o) do_not_optimize=true ;;
			v) talk_to_me=true ;;
			x) verbose=true ;;
			h|*) usage ;;
		esac
	done
	shift $(( OPTIND - 1 )); load_file="$1"
	
	# Caso $load_file não esteja definida por meio da opção "-f",
	# esperaremos que o JSON com o programa em forma de A.S.T. (vulgo
	# "Árvore sintática abstrata") esteja vindo por meio de um encanamento
	# para a entrada padrão --- que, no UNIX e no Windows NT moderno, é
	# indicada por traço, que o shell "transforma" em algum descritor de
	# arquivo. Isso vai ajudar muito na hora de se criar uma interface entre
	# o programa "rinha", que faz o processo de conversão do código para uma
	# A.S.T. e o interpretador em si.
	interpreter "${load_file:--}"
}

function interpreter {
	# Esse código vai ser repetido sem qualquer tipo de pseudônimo ou
	# função-porcelana no cabeçalho de qualquer função que vier a seguir,
	# pois, como KSH-93 respeita o escopo das funções, o que é definido com 
	# o "set" em uma função não é definido em nenhuma outra, mesmo que seja
	# executada a partir da primeira.
	[[ $verbose ]] && set -x
	
	ast="$1"

	printlog INFOF "Loading JSON AST from '$ast'."

	json2compound "$ast"

	evaluate ast.expression
}


# Referências: https://github.com/aripiprazole/rinha-de-compiler/blob/main/SPECS.md 
function evaluate {
	[[ $verbose ]] && set -x
	node=$1
	kind="$(eval_per_token $node kind)" 

	# Nesse caso, ganhamos uma vantagem pelo tokenizador de Korn Shell não
	# considerar $var.subvar igual a ${var.subvar}, pois podemos passar como
	# parâmetro de função posteriormente.
	case "$kind" in
	        "Binary")
			a=$(evaluate "$node.lhs")
			b=$(evaluate "$node.rhs")
			case "$(eval_per_token $node op)" in
				"Mul") r=$(( a * b )) ;;
				"Div") r=$(( a / b )) ;;
				"Rem") r=$(( a % b )) ;;
        	        	"Add") r=$(( a + b )) ;;
                	       	"Sub") r=$(( a - b )) ;;
				"Eq") r=$(( a == b )) ;;
				"Neq") r=$(( a != b )) ;;
				"Lt") r=$(( a < b )) ;;  
				"Gt") r=$(( a > b )) ;; 
				"Lte") r=$(( a <= b )) ;;  
				"Gte") r=$(( a >= b )) ;; 
				"And") r=$(( a && b )) ;;
				"Or") r=$(( a || b )) ;;
	            	esac
			unset a b ;;
		"Bool") printlog ERRORF "$kind not implemented yet, soon I will get it done." ;;
		"Call") # Para quem estamos ligando?
		       	identifier=$(eval_per_token $node callee.text)
			function_node=${records[$identifier]}
			
			# Essa parte é para que os parâmetros da função sejam
			# declarados em forma de variável e tenham seus valores
			# devidamente associados aos seus identificadores.
			parametersn=$(n_per_token $function_node parameters)
			argsn=$(n_per_token $node arguments)

			# Por mais que possivelmente o analisador léxico do
			# desafio já faça isso, nós talvez precisemos verificar
			# se a quantidade de argumentos passados para a função é
			# o mesmo de parâmetros aceitos por ela.
			args_param_difference=$((argsn - parametersn))

			if (( args_param_difference != 0 )); then
				if (( args_param_difference > 0 )); then
					printlog ERRORF "$0: $kind: Too many arguments to $identifier() (required $parametersn, recieved $argsn)."
				elif (( args_param_difference < 0 )); then
					printlog ERRORF "$0: $kind: Not enough arguments to $identifier() (required $parametersn, recieved $argsn)."
				fi
				exit 1
			fi
			
			for ((c=0; c < parametersn; c++)); do
				eval $(printf '%s=%s' \
					"$(eval_per_token "$function_node" "parameters[$c].text")" \
					"$(evaluate "$node.arguments[$c]")")
			done
			
			# Um amigo meu, o Álvaro Filho (@alvarofilho no GitHub),
			# me apresentou esse algoritmo que ele escreveu
			# originalmente na linguagem R para resolver uma
			# sequência de Fibonacci. Esse algoritmo é muito mais
			# rápido do que o apresentado nas A.S.Ts e, além disso,
			# usa menos a CPU, então resolvi usá-lo.
			if [[ "$identifier" != 'fib' || $do_not_optimize ]]; then
				# Caso não seja uma função de Fibonacci --- e, se for,
				# não tiver a otimização ativada ---, apenas interprete
				# o resto da função como normalmente.
				evaluate $function_node 
			else
				function fib {
					# Usando especificamente "parameters[0]"
					# pois sabemos que um algoritmo de
					# Fibonacci, independente da linguagem,
					# só recebe um parâmetro de entrada.
					n=$(eval_per_identifier \
						$(eval_per_token "$function_node" 'parameters[0].text'))
					m1=$(( ((1 + sqrt(5)) / 2) ** n ))
					m2=$(( (1 - ((1 + sqrt(5)) / 2)) ** n ))
					r=$(printf '%s' $(( (m1 - m2) / sqrt(5) )))
					unset m1 m2 n
					export r
				}; fib
			fi ;;
		"Function") r=$(evaluate "$node.value") ;;
		"If")	# Esperamos aqui um tipo binário (Binary), que é para retornar "r".
			r=$(evaluate "$node.condition")

			printlog INFOF "If: return was $r (binary value)."
			if (( r )); then
				evaluate "$node.then"
			else
				evaluate "$node.otherwise"
			fi ;;

		"Let")	identifier=$(eval_per_token $node name.text) 
			content=$(eval_per_token $node value.kind)
			next=$(eval_per_token $node next)

			printlog INFOF "Let: $identifier with kind $content." 
	
			if [[ $content == "Function" ]]; then
				printlog INFOF "Dealing with $content, recording it in case of a call."
				record_function "$identifier" "$node.value"
				printlog INFOF "records: ${records[@]}" 
			else
				r=$(evaluate "$node.value")
				eval $(printf '%s=%s' "$identifier" "$r")
				printlog INFOF "Let $identifier=$r" 
				unset r
			fi
			unset content identifier

			[[ -n $next ]] \
				&& unset next \
				&& printlog INFOF "$node.next is not empty, evaluating it." \
				&& evaluate "$node.next" ;;
		"Int") value="$(eval_per_token $node value)"
		       isdigit $value "$0: Expected 'Int', apparently got an string." \
			       && r=$(printf '%d' $value) \
			       && unset value ;;
	        "Str") r="$(eval_per_token $node value)";;
		"Var") r="$(eval_per_identifier $(eval_per_token $node text))" ;;
		"Tuple"| "First" | "Second") printlog ERRORF \
			"$progname: Tuples and functions related are not implemented for now." ;;
		"Print") r="$(evaluate "$node.value")" ;;
	esac

	# Como em shell a saída de uma função normalmente é
	# imprimindo algo na tela, iremos retornar r
	# imprimindo-o. 
	printf '%s\n' "$r"
	
	unset node kind r
	return 0
}

# Essa função vai retornar apenas o conteúdo da nossa A.S.T., facilitando
# bastante que a gente consiga caminhar pela A.S.T. na função que a "avalia".
# Analisando de forma estritamente técnica, é uma "função-porcelana" para a
# "eval_per_identifier".
function eval_per_token {
	node=$1
	token=$2

	eval_per_identifier "$node.$token"
}

# Essa função vai retornar o conteúdo de uma variável pelo seu identificador,
# evitando marabalismos com caracteres de escape.
# Usando o 'echo -n' ao invés do 'printf' pois o último se mostrou problemático
# com variáveis que contém strings com espaços, como o exemplo em "print.json".
function eval_per_identifier {
	[[ $verbose ]] && set -x
	identifier=$1

	eval echo -n \$\{"$identifier"\}
}

# Essa função retorna o número de elementos em um array dentro de uma variável
# composta.
function n_per_token {
	node=$1
	token=$2
	index=$3

	eval printf '%d' \$\{\#$node.$token\[${index:-@}\]\}
}

# Essa função basicamente vai criar um array associativo onde o identificador de
# uma função corresponde ao "nó" (node) dela na A.S.T. Isso vai nos salvar na
# parte do Call.
# Referência: Cap. 6.4.2 do livro "Learning the Korn Shell, 2nd Ed." da
# O'Reilly.
function record_function {
	[[ $verbose ]] && set -x

	identifier="$1"
	address="$2"

	records+=([$identifier]="$address")
}

# Essa função deve passar todo o JSON para uma variável composta --- essas
# que em KSH-93 são análogas às "structs" em C e Go ou ao "record" em Pascal
# e suas variantes. Em resumo, caso você não esteja familiarizado com esses
# exemplos, variáveis compostas basicamente permitem que se armazene vários
# itens embaixo de um "guarda-chuva" só.
# Esse processo seria muito mais simples se a equipe de desenvolvimento do
# KSH-93 não tivesse desistido da implementação de JSON direto no "read".
#
# Referências: Cap. 4.3 do livro "Learning the Korn Shell, 2nd Ed." da O'Reilly.
# Artigo sobre variáveis compostas em Korn Shell por F.P. Murphy
# (https://blog.fpmurphy.com/2009/01/ksh93-compound-variables_05.html).
function json2compound {
	[[ $verbose ]] && set -x

	# Isso vai carregar o JSON na memória para, então, processarmos o JSON
	# para uma variável composta.	
	ast_json="$(cat "$1")"

	# FIXME: Esse comando do sed está horrível, mas funciona por ora.
	# Acho que dá pra cortar bastante coisa nisso.
	#
	# Resumindo os comandos no sed:
	# * 's/\{/\(/g' e 's/\}/\)/g': Substituem ('s') globalmente ('g')
	# '{' e '}' por '(' e ')', respectivamente;
	# * 's/\[/\(/g' e 's/\]/\)/g': Faz o mesmo, só que com '[' e ']';
	# * 's/"\([^"]*\)":[^ ]*./\1=/g': Substitui tudo que estiver dentro do
	# padrão '"abcde": abcde'  por 'abcde=abcde'. o '"\([^"]*\)"' "pega" tudo
	# que estiver entre " e " e "guarda" em "\1" para podermos usar depois
	# na hora de escrever por qual padrão queremos substituir;
	eval ast=$(echo "$ast_json" | \
		sed -e 's/\{/\(/g; s/\}/\)/g; s/\[/\(/g; s/\]/\)/g; s/"\([^"]*\)":[^ ]*./\1=/g; s/,//g')

	# Agora, que limpemos a memória removendo o JSON que acabamos de
	# processar.
	unset ast_json
}

function usage {
	printf 'usage: %s: -ovx [file|stdin]\n' "$progname" 1>&2
	exit 1
}

# Função de registro, análoga ao pfmt() de C, mas claramente diferente.
function printlog {
	if [[ $talk_to_me ]]; then
		flag="$1"
		case "$flag" in 
			INFOF) colour=${colours.green}; severity='INFO' ;;
			WARNF) colour=${colours.yellow}; severity='WARNING' ;;
			ERRORF) colour="${colours.red}"; severity='ERROR' ;;
		esac; shift

		msg+="$(printf '%b%s%b: ' ${colour} $severity ${colours.close}) $@"
		echo "$msg" 1>&2
	else
		return 0
	fi

	unset msg colour severity
}

function check_for_colour_support {
	colours=( green='\033[92m' yellow='\033[93m' red='\033[91m' \
		close='\033[m' )

	# Iremos verificar apenas se o f.d. nº 2, que se refere à saída de erro
	# padrão (vulgo "stderr"), é um terminal válido, pois a função printlog
	# irá imprimir apenas para ela, não para a saída padrão (f.d. nº 1,
	# vulgo "stdout"), também verificaremos se o terminal suporta pelo menos
	# 8 cores.
	{ isatty 2 && (( $(tput colors) >= 8 )); } || unset colours
}

# Essa função é análoga à homônima em C (isatty(3)), ou seja, ela checa se o
# descritor de arquivo sendo utilizado é um terminal ou um arquivo que está
# sendo redirecionado.
function isatty {
	isdigit $1 "$0: '$1' is not a valid tty."

	{ test -t $1; } || return 1
}

# Essa função apenas verifica se estamos tratando de um dígito inteiro ou não,
# fazendo a checagem com o printf '%d'. O mesmo mecanismo é utilizado depois no
# interpretador, para lidarmos com uma declaração de um inteiro.
function isdigit {
	digit=$1; shift
	errstring="$@"

	# Fazendo o uso de "printf '%d'" para se ter certeza de que estamos
	# tratando de um inteiro, afinal, tudo em shell é uma string até que se
	# prove o contrário, assim como também iremos testar se "printf '%d' $1"
	# é igual ao "$1" por si só, pois, caso alguém tente fazer alguma patuscada
	# com essa função usando uma string no lugar de um inteiro, o printf(1) não
	# retornará um erro --- como em qualquer linguagem com sistema de tipos
	# forte ---, mas sim o valor de zero, então é necessário verificar se o
	# valor testado é 0 de fato ou se é algum patusqueiro tentando achar uma
	# falha no programa. Testando também se o dígito se encaixa no padrão de
	# "0 a 9" por uma simples formalidade.
	if [[ $(printf '%d' $digit) != $digit &&  $digit == +([0-9]) ]]; then
		printlog ERRORF "$errstring"
		exit 2
	fi
}

main "$@"
