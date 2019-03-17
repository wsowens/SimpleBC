grammar SimpleBC;
/* This grammar was created to follow the specification provided here:
   https://www.gnu.org/software/bc/manual/html_mono/bc.html */


/* TODO: move this comment value assignments in bc return the value
however, if you only assign the value,
the statement the result is not printed */

/*bc does not allow the defining inside statement blocks or other functions
 therefore, we outline it here it here*/
file:
    | (statement | define) (STATE_SEP (statement|define))*
    ;

define:
    'define' name=ID '(' (args+=ID (',' args+=ID)*)? ')' LINE_END  '{' states+=statement (STATE_SEP states+=statement)* '}' ; 

statement:
    | expr   /* expressions should be printed, unless they are assignments */
    | STRING /* strings should be printed literally */
    | 'print' printable (PRINT_SEP printable)* /* refine this to allow for spacew */
    | '{' statement (STATE_SEP statement)* '}' 
    | 'if' '(' cond=expr ')' stat1=statement ('else' stat2=statement)?
    | 'while' '(' cond=expr ')' stat=statement
    | 'for' '(' pre=expr ';' cond=expr ';' post=expr ')'
    | 'break'
    | 'continue'
    | 'halt' /* end bc upon execution */
    | 'return' ( value=expr )? /* if no value is provided, return 0 */
    ;

printable:
    | expr
    | STRING
    ;

expr:
      op='++' ID
    | op='--' ID 
    | ID op='++' 
    | ID op='--'
    | op='-' e=expr
    | <assoc=right> el=expr op='^' er=expr
    | el=expr op=('*'|'/') er=expr
    | el=expr op=('+'|'-') er=expr
    | '(' e=expr ')'
    /* assignment */
    | ID '=' expr
    /* relational expressions */
    | el=expr '<'  er=expr
    | el=expr '<=' er=expr
    | el=expr '>'  er=expr
    | el=expr '>=' er=expr
    | el=expr '==' er=expr
    | el=expr '!=' er=expr
    /* boolean expressions */
    | op='!' e=expr
    | el=expr op='&&' er=expr
    | el=expr op='||' er=expr
    | FLOAT
    | ID
    | func
    ;

list: 'print' ID PRINT_SEP ID ;

func /* returns [BigDecimal i] */:
    'read()' /* { $i = new BigDecimal(input.nextLine().trim()); } */
    | ID '(' arg=expr ')' /* { $i=fnMap.get($ID.text).execute($arg.i).setScale(scale, BigDecimal.ROUND_DOWN); } */
    ;


/* Lexer rules */
ID: [_A-Za-z]+;
//FLOAT: [0-9]*[.]?[0-9]+;
PRINT_SEP: ','; 
//STATE_SEP: (LINE_END) | ([;]) | ([;]LINE_END) ;
//STRING: ["].*?["]; /* lazy definition of string */
//WS : [ \t]+ -> skip ;
//P_COMMENT: '#' (.)*? LINE_END -> skip;
//C_COMMENT: [/][*](.|[\r\n])*?[*][/] -> skip;
//LINE_END: '\r'?'\n';