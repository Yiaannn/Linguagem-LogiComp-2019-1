%{
#include <string>
#include "node.h"
#include "parser.hpp"
#define SAVE_TOKEN yylval.string = new std::string(yytext, yyleng)
#define TOKEN(t) (yylval.token = t)
extern "C" int yywrap() { }
%}

%%

[ \t\n]                 ;
// deixar minhs coisas menos tradicionais dentro desse bloco
"alias" return TOKEN(T_ALIAS);
"package" return TOKEN(T_PACKAGE);
"!" return TOKEN(T_ALIAS_CALL); //meu ! não representa o not lógico, posso reconsiderar esse token depois
//
[a-zA-Z_][a-zA-Z0-9_]*  SAVE_TOKEN; return T_IDENTIFIER;
[0-9]+.[0-9]*           SAVE_TOKEN; return T_DOUBLE;
[0-9]+                  SAVE_TOKEN; return T_INTEGER;
"="                     return TOKEN(T_EQUAL);
"=="                    return TOKEN(T_CEQ);
"!="                    return TOKEN(T_CNE);
"<"                     return TOKEN(T_CLT);
"<="                    return TOKEN(T_CLE);
">"                     return TOKEN(T_CGT);
">="                    return TOKEN(T_CGE);
"("                     return TOKEN(T_LPAREN);
")"                     return TOKEN(T_RPAREN);
"{"                     return TOKEN(T_LBRACE);
"}"                     return TOKEN(T_RBRACE);
"."                     return TOKEN(T_DOT); //por enquanto não uso este
","                     return TOKEN(T_COMMA);
"+"                     return TOKEN(T_PLUS);
"-"                     return TOKEN(T_MINUS);
"*"                     return TOKEN(T_MUL);
"/"                     return TOKEN(T_DIV);
"%"                     return TOKEN(T_MOD); //adicionei este também
.                       printf("Unknown token!n"); yyterminate();

%%
