grammar SimpleBC;
/* This grammar was created to follow the specification provided here:
   https://www.gnu.org/software/bc/manual/html_mono/bc.html */
@header {
abstract class ASTNode {
    ArrayList<ASTNode> children = new ArrayList<ASTNode>();

    public String toString(){
        String str = "( " + this.getClass().getSimpleName();
        for (ASTNode child : this.children) {
            str = str + " " + child;
        }
        return str + ")";
    }

    public abstract BigDecimal visit(ArrayList<Env> env_stack);
}

abstract class ExprNode extends ASTNode {
}

abstract class UnaryExpr extends ExprNode {
    ASTNode child;
    public UnaryExpr( ExprNode child) {
        this.child = child;
        this.children.add(child);
    }
}

abstract class BinaryExpr extends ExprNode {
    ASTNode left;
    ASTNode right;
    public BinaryExpr(ExprNode left, ExprNode right) {
        this.left = left;
        this.right = right;
        this.children.add(left);
        this.children.add(right);
    }
    
}

class PreInc extends UnaryExpr {
    public PreInc(ExprNode child) {
        super(child);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        //TODO: do the proper memory manipulation
        return this.child.visit(env_stack).add(BigDecimal.ONE);
    }
}

class PreDec extends UnaryExpr {
    public PreDec(ExprNode child) {
        super(child);
    }
    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        //TODO: do the proper memory manipulation
        return this.child.visit(env_stack).subtract(BigDecimal.ONE);
    }
}

class PostInc extends UnaryExpr {
    public PostInc(ExprNode child) {
        super(child);
    }
    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        //TODO: do the proper memory manipulation
        return this.child.visit(env_stack).add(BigDecimal.ONE);
    }
}

class PostDec extends UnaryExpr {
    public PostDec(ExprNode child) {
        super(child);
    }
    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        //TODO: do the proper memory manipulation
        return this.child.visit(env_stack).subtract(BigDecimal.ONE);
    }
}

class Negate extends UnaryExpr {
    public Negate(ExprNode child) {
        super(child);
    }
    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        return this.child.visit(env_stack).negate();
    }
}

class Power extends BinaryExpr {
    public Power(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        return this.left.visit(env_stack).pow(this.right.visit(env_stack).intValue());
    }
}

class Mult extends BinaryExpr {
    public Mult(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        return this.left.visit(env_stack).multiply(this.right.visit(env_stack));
    }
}

class Div extends BinaryExpr {
    public Div(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        //TODO: change this later
        return this.left.visit(env_stack).divide(this.right.visit(env_stack), 20, BigDecimal.ROUND_DOWN);
    }
}

class Add extends BinaryExpr {
    public Add(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        return this.left.visit(env_stack).add(this.right.visit(env_stack));
    }
}

class Sub extends BinaryExpr {
    public Sub(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        return this.left.visit(env_stack).subtract(this.right.visit(env_stack));
    }
}

class Assign extends ExprNode {
    String id;
    ExprNode child;
    public Assign(String id, ExprNode child) {
        this.id = id;
    }

    public BigDecimal visit(ArrayList<Env> env_stack) {
        //TODO: perform memory operations as appropriate
        return BigDecimal.ZERO;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + " " + this.child + ")";
    }
}

class Lt extends BinaryExpr {
    public Lt(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        int result = left.visit(env_stack).compareTo(right.visit(env_stack));
        if (result == -1) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Le extends BinaryExpr {
    public Le(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        int result = left.visit(env_stack).compareTo(right.visit(env_stack));
        if (result == -1 || result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Gt extends BinaryExpr {
    public Gt(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        int result = left.visit(env_stack).compareTo(right.visit(env_stack));
        if (result == 1) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Ge extends BinaryExpr {
    public Ge(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        int result = left.visit(env_stack).compareTo(right.visit(env_stack));
        if (result == 1 || result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Eq extends BinaryExpr {
    public Eq(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        int result = left.visit(env_stack).compareTo(right.visit(env_stack));
        if ( result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class NotEq extends BinaryExpr {
    public NotEq(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        int result = left.visit(env_stack).compareTo(right.visit(env_stack));
        if ( result != 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}


class Not extends UnaryExpr {
    public Not(ExprNode child) {
        super(child);
    }
        
    public BigDecimal visit(ArrayList<Env> env_stack) {
        if (this.child.visit(env_stack).equals(BigDecimal.ZERO)) { 
            return BigDecimal.ONE; 
        } 
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class And extends BinaryExpr {
    public And(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        if (!(left.visit(env_stack).equals(BigDecimal.ZERO)) && !(right.visit(env_stack).equals(BigDecimal.ZERO))) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Or extends BinaryExpr {
    public Or(ExprNode left, ExprNode right) {
        super(left, right);
    }

    public BigDecimal visit(ArrayList<Env> env_stack)
    {
        if (!(left.visit(env_stack).equals(BigDecimal.ZERO)) || !(right.visit(env_stack).equals(BigDecimal.ZERO))) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Var extends ExprNode {
    String id;

    public Var(String id) {
        
        this.id = id;
    }

    public BigDecimal visit(ArrayList<Env> env_stack) {
        return BigDecimal.ZERO;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }

}

    class Const extends ExprNode {
    BigDecimal value;

    public Const(BigDecimal value) {
        
        this.value = value;
    }

    public BigDecimal visit(ArrayList<Env> env_stack) {
        return this.value;
    }

    public String toString()
    {
        return "(" + this.getClass().getSimpleName() + " " + this.value.toString() + ")";
    }
}
}

file: 
    | (statement | define) ( ( SEMI | ENDLINE | SEMI ENDLINE ) (statement|define))*
    ;

define:
    'define' name=ID '(' (args+=ID (',' args+=ID)*)? ')' ENDLINE? '{' states+=statement ( ( SEMI | ENDLINE | SEMI ENDLINE ) states+=statement)* '}' ; 

statement:
    | expr   /* expressions should be printed, unless they are assignments */
    | STRING /* strings should be printed literally */
    | 'print' printable ((SEMI | COMMA) printable)* /* refine this to allow for spacew */
    | '{' statement ( ( SEMI | ENDLINE | SEMI ENDLINE ) statement)* '}' 
    | 'if' '(' cond=expr ')' stat1=statement ('else' stat2=statement)?
    | 'while' '(' cond=expr ')' ENDLINE? stat=statement
    | 'for' '(' pre=expr SEMI cond=expr SEMI post=expr ')'
    | 'break'
    | 'continue'
    | 'halt' /* end bc upon execution */
    | 'return' ( value=expr )? /* if no value is provided, return 0 */
    ;

printable:
    | expr
    | STRING
    ;

expr [returns ExprNode]:
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
 //   | func
    ;

func /* returns [BigDecimal i] */:
    'read()' /* { $i = new BigDecimal(input.nextLine().trim()); } */
    | ID '(' (args+=expr (',' args+=expr)*)?  ')' /* { $i=fnMap.get($ID.text).execute($arg.i).setScale(scale, BigDecimal.ROUND_DOWN); } */
    ;

/* Lexer rules */
ID: [_A-Za-z]+;
FLOAT: [0-9]*[.]?[0-9]+; 
STRING: ["].*?["]; /* lazy definition of string */
WS : [ \t]+ -> skip ;
C_COMMENT: [/][*](.)*?[*][/] -> skip;
P_COMMENT: '#' (.)*? ENDLINE -> skip;
ENDLINE: '\r'?'\n';
SEMI: ';';
COMMA: ',';