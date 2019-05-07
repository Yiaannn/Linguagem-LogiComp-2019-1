%{
    #include "node.h"
    NBlock *programBlock; /* the top level root node of our final AST */

    extern int yylex();
    void yyerror(const char *s) { printf("ERROR: %sn", s); }
%}

/* Represents the many different ways we can access our data */
%union {
    Node *node;
    NBlock *block;
    NExpression *expr;
    NStatement *stmt;
    NIdentifier *ident;
    NVariableDeclaration *var_decl;
    std::vector<NVariableDeclaration*> *varvec;
    std::vector<NExpression*> *exprvec;
    std::string *string;
    int token;
}

/* Define our terminal symbols (tokens). This should
   match our tokens.l lex file. We also define the node type
   they represent.
 */
%token <string> T_IDENTIFIER T_INTEGER T_DOUBLE
%token <token> T_CEQ T_CNE T_CLT T_CLE T_CGT T_CGE T_EQUAL
%token <token> T_LPAREN T_RPAREN T_LBRACE T_RBRACE T_COMMA T_DOT
%token <token> T_PLUS T_MINUS T_MUL T_DIV
%token <token> T_ALIAS_CALL T_PACKAGE T_ALIAS //deixar os meus aqui

/* Define the type of node our nonterminal symbols represent.
   The types refer to the %union declaration above. Ex: when
   we call an ident (defined by union type ident) we are really
   calling an (NIdentifier*). It makes the compiler happy.
 */
%type <ident> ident
%type <expr> numeric expr
//%type <varvec> func_decl_args
//%type <exprvec> call_args
%type <exprvec> expression_list
%type <block> program stmts block alias_call
//%type <stmt> stmt var_decl func_decl
%type <stmt> stmt var_decl package_initialization alias_declaration
%type <token> comparison

/* Operator precedence for mathematical operators */
%left T_PLUS T_MINUS
%left T_MUL T_DIV

%start program

%%

program : stmts { programBlock = $1; }
        ;

stmts : stmt { $$ = new NBlock(); $$->statements.push_back($<stmt>1); }
      | stmts stmt { $1->statements.push_back($<stmt>2); }
      ;

stmt : var_decl //| package_declaration //| func_decl
     | expr { $$ = new NExpressionStatement(*$1); }
     ;

block : T_LBRACE stmts T_RBRACE { $$ = $2; }
      | T_LBRACE T_RBRACE { $$ = new NBlock(); }
      ;

var_decl : ident ident { $$ = new NVariableDeclaration(*$1, *$2); }
         | ident ident T_EQUAL expr { $$ = new NVariableDeclaration(*$1, *$2, $4); }
         ;

/*
func_decl : ident ident TLPAREN func_decl_args TRPAREN block
            { $$ = new NFunctionDeclaration(*$1, *$2, *$4, *$6); delete $4; }
          ;

func_decl_args : { $$ = new VariableList(); } //blank
               | var_decl { $$ = new VariableList(); $$->push_back($<var_decl>1); }
               | func_decl_args TCOMMA var_decl { $1->push_back($<var_decl>3); }
               ;
*/

//meu package tem 3 partes, initialization, declaration e operation
//initialization é algo próximo de declaração+inicialização de variável, exceto com potencialmente múltiplas entradas
package_initialization : T_PACKAGE ident T_LPAREN expression_list T_RPAREN { $$ = new NPackageDeclaration(*$2, *$3);} //deleto meu expression_list?
                       ;

expression_list : { $$ = new ExpressionList(); } //blank
                | expr { $$ = new ExpressionList(); $$->push_back($1); }
                | expression_list T_COMMA expr { $1->push_back($3); }
                ;

//quanto à declaração, posso tentar pensar no meu package como um struct

ident : T_IDENTIFIER { $$ = new NIdentifier(*$1); delete $1; }
      ;

numeric : T_INTEGER { $$ = new NInteger(atol($1->c_str())); delete $1; }
        | T_DOUBLE { $$ = new NDouble(atof($1->c_str())); delete $1; }
        ;

expr : ident T_EQUAL expr { $$ = new NAssignment(*$<ident>1, *$3); }
     //| ident T_LPAREN call_args T_RPAREN { $$ = new NMethodCall(*$1, *$3); delete $3; }
     | ident { $<ident>$ = $1; }
     | numeric
     | expr comparison expr { $$ = new NBinaryOperator(*$1, $2, *$3); }
     | T_LPAREN expr T_RPAREN { $$ = $2; }
     ;

/*
call_args : { $$ = new ExpressionList(); } //blank
          | expr { $$ = new ExpressionList(); $$->push_back($1); }
          | call_args TCOMMA expr  { $1->push_back($3); }
          ;
*/

//meus alias são semelhantes a funções, usar elas de referência
//conferir se meus alias recebiam parâmetros
alias_call : T_ALIAS_CALL ident { $$ = new NAliasCall(*$2); }
           ;

alias_declaration : T_ALIAS ident stmts { $$ = NAliasDeclaration( *$2, *$3); }
                  ;

comparison : T_CEQ | T_CNE | T_CLT | T_CLE | T_CGT | T_CGE
           | T_PLUS | T_MINUS | T_MUL | T_DIV
           ;

%%
