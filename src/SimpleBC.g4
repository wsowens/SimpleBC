grammar SimpleBC;
@header{
import java.util.HashMap;
}

@members{
    public interface Fn {
        public double execute(double arg);
    }
    public HashMap<String, Fn> fnMap = new HashMap<String, Fn>();
}

/*parser rules */
exprList: topExpr ( EXPR_END topExpr)* EXPR_END? ;

varDef: VAR ID '=' arith_expr;

topExpr: 
      arith_expr { System.out.println("Result: "+ Double.toString($arith_expr.i));} 
    ;

arith_expr returns [double i]:
      el=arith_expr op='^' er=arith_expr { $i=Math.pow($el.i, $er.i); }
    | el=arith_expr op='*' er=arith_expr { $i=$el.i*$er.i; }
    | el=arith_expr op='/' er=arith_expr { $i=$el.i/$er.i; }
    | el=arith_expr op='+' er=arith_expr { $i=$el.i+$er.i; }
    | el=arith_expr op='-' er=arith_expr { $i=$el.i-$er.i; }
    | FLOAT { $i=Double.parseDouble($FLOAT.text); }
    | ID
    | func
    | '(' e=arith_expr ')'
    ;

func returns [double i]:
     ID '(' arg=arith_expr ')' { $i=fnMap.get($ID).execute($arg.i); };

/*lexer rules*/
COMMENT: [/][*](.)*?[*][/] -> skip;
/*
Comments is defined with the lazy definition so that 
we match the nearest * /
*/

VAR: 'var';  // keyword
ID: [_A-Za-z]+;
FLOAT: [0-9]+([.][0-9]*)?;
EXPR_END: [(\r?\n);];
WS : [ \t]+ -> skip ;
