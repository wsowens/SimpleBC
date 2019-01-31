grammar Calculator;

/*parser rules */
exprList: topExpr ( ';' topExpr)* ';'? ;

varDef: VAR ID '=' expr;

topExpr: 
    comment* expr comment* { System.out.println("Result: "+ Double.toString($expr.i));} 
    ;

expr returns [double i]:
      el=expr op='*' er=expr { $i=$el.i*$er.i; }
    | el=expr op='/' er=expr { $i=$el.i/$er.i; }
    | el=expr op='+' er=expr { $i=$el.i+$er.i; }
    | el=expr op='-' er=expr { $i=$el.i-$er.i; }
    | INT { $i=Double.parseDouble($INT.text); }
    | ID
    | '(' e=expr ')'
    ;

comment: COMMENT;

/*token definition*/
COMMENT: [/][*](.)*?[*][/];
/*
Comments is defined with the lazy definition so that 
we match the nearest * /
*/
VAR: 'var';  // keyword
ID: [_A-Za-z]+;
INT: [0-9]+ ;
WS : [ \t\r\n]+ -> skip ;