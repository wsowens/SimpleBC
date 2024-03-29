grammar SimpleBC;
/* This grammar was created to follow the specification provided here:
   https://www.gnu.org/software/bc/manual/html_mono/bc.html */
@header {
import java.util.ArrayList;
import java.math.BigDecimal;
import java.util.HashMap;
}

/* classes used for constructing and evaluating the AST */
@members {
/* abstract class for all nodes in the tree */
abstract class ASTNode {
    ArrayList<ASTNode> children = new ArrayList<ASTNode>();
    public String toString(){
        String str = "(" + this.getClass().getSimpleName();
        for (ASTNode child : this.children) {
            str = str + " " + child;
        }
        return str + ")";
    }
    abstract Object visit(Env env) throws KeywordExcept;
}

/* interface for nodes to be passed as 'print' arguments */
interface Printable {
    public Object visit(Env env, boolean doPrint) throws KeywordExcept;
}

/* root of the tree */
class Root extends ASTNode{
    void add(ASTNode an) {
        if (an != null) {
            //System.err.println("Adding: " + an);
            children.add(an);
        }
    }

    Object visit(Env env) {
        for (ASTNode child : children) {
            try {
                child.visit(env);
            }
            catch (KeywordExcept ex) {
                System.err.println(ex.getMessage());
            }
        }
        return null;
    }
}

/* top expression for all ExprNodes */
class Expr extends ASTNode implements Printable {
    ExprNode child;
    Expr(ExprNode n) {
        child = n;
        children.add(n);
    }

    public BigDecimal visit(Env env) throws KeywordExcept {
        /* recursively visit each child */
        return visit(env, true);
    }

    public BigDecimal visit(Env env, boolean doPrint) throws KeywordExcept {
        BigDecimal result = child.visit(env);
        /* if printing is enabled, print the result*/
        if (doPrint) { 
            /* ...unless that result was an assign statement */
            if ( ! (child instanceof Assign) ) {
                env.globals().put("last", result);
                System.out.println(result);
            }
        }
        return result;
    }
}

/* abstract class for ExprNodes*/
abstract class ExprNode extends ASTNode {
    abstract BigDecimal visit(Env env);
    /* abstract ExprNode optimize(); */
}

abstract class UnaryExpr extends ExprNode {
    ExprNode child;
    UnaryExpr( ExprNode child) {
        this.child = child;
        this.children.add(child);
    }
}

abstract class BinaryExpr extends ExprNode {
    ExprNode left;
    ExprNode right;
    BinaryExpr(ExprNode left, ExprNode right) {
        this.left = left;
        this.right = right;
        this.children.add(left);
        this.children.add(right);
    }
}

/* post/pre increment/decrement classes */
class PreInc extends ExprNode {
    String id;
    PreInc(String id) {
        this.id = id;
    }

    BigDecimal visit(Env env)
    {
        BigDecimal current = env.getVar(id);
        env.putVar(id, current.add(BigDecimal.ONE));
        return current.add(BigDecimal.ONE);
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PreDec extends ExprNode {
    String id;
    PreDec(String id) {
        this.id = id;
    }
    BigDecimal visit(Env env)
    {
        BigDecimal current = env.getVar(id);
        env.putVar(id, current.subtract(BigDecimal.ONE));
        return current.subtract(BigDecimal.ONE);
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PostInc extends ExprNode {
    String id;
    PostInc(String id) {
        this.id = id;
    }

    BigDecimal visit(Env env)
    {
        BigDecimal current = env.getVar(id);
        env.putVar(id, current.add(BigDecimal.ONE));
        return current;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class PostDec extends ExprNode {
    String id;
    PostDec(String id) {
        this.id = id;
    }

    BigDecimal visit(Env env)
    {
        BigDecimal current = env.getVar(id);
        env.putVar(id, current.subtract(BigDecimal.ONE));
        return current;
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }
}

class Negate extends UnaryExpr {
    Negate(ExprNode child) {
        super(child);
    }

    BigDecimal visit(Env env)
    {
        return this.child.visit(env).negate();
    }
}

class Power extends BinaryExpr {
    Power(ExprNode left, ExprNode right) {
        super(left, right);
    }
    BigDecimal visit(Env env)
    {
        return this.left.visit(env).pow(this.right.visit(env).intValue());
    }
}

class Mul extends BinaryExpr {
    Mul(ExprNode left, ExprNode right) {
        super(left, right);
    }
    BigDecimal visit(Env env)
    {
        return this.left.visit(env).multiply(this.right.visit(env));
    }
}

class Div extends BinaryExpr {
    Div(ExprNode left, ExprNode right) {
        super(left, right);
    }
    BigDecimal visit(Env env)
    {
        return this.left.visit(env).divide(this.right.visit(env), env.scale, BigDecimal.ROUND_DOWN);
    }
}

class Add extends BinaryExpr {
    Add(ExprNode left, ExprNode right) {
        super(left, right);
    }
    BigDecimal visit(Env env)
    {
        return this.left.visit(env).add(this.right.visit(env));
    }
}

class Sub extends BinaryExpr {
    Sub(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        return this.left.visit(env).subtract(this.right.visit(env));
    }
}

class Assign extends ExprNode {
    String id;
    ExprNode child;
    Assign(String id, ExprNode child) {
        this.id = id;
        this.child = child;
    }
    BigDecimal visit(Env env) {
        BigDecimal value = child.visit(env);
        env.putVar(id, value);
        return value;
    }
    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + " " + this.child + ")";
    }
}

/* relational operators */
class Lt extends BinaryExpr {
    Lt(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == -1) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Le extends BinaryExpr {
    Le(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == -1 || result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Gt extends BinaryExpr {
    Gt(ExprNode left, ExprNode right) {
        super(left, right);
    }
    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == 1) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Ge extends BinaryExpr {
    Ge(ExprNode left, ExprNode right) {
        super(left, right);
    }
    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if (result == 1 || result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Eq extends BinaryExpr {
    Eq(ExprNode left, ExprNode right) {
        super(left, right);
    }
    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if ( result == 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class NotEq extends BinaryExpr {
    NotEq(ExprNode left, ExprNode right) {
        super(left, right);
    }
    BigDecimal visit(Env env)
    {
        int result = left.visit(env).compareTo(right.visit(env));
        if ( result != 0) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

/* logical operators */
class Not extends UnaryExpr {
    Not(ExprNode child) {
        super(child);
    }
    BigDecimal visit(Env env) {
        if (this.child.visit(env).equals(BigDecimal.ZERO)) { 
            return BigDecimal.ONE; 
        } 
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class And extends BinaryExpr {
    And(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        if (!(left.visit(env).equals(BigDecimal.ZERO)) && !(right.visit(env).equals(BigDecimal.ZERO))) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

class Or extends BinaryExpr {
    Or(ExprNode left, ExprNode right) {
        super(left, right);
    }

    BigDecimal visit(Env env)
    {
        if (!(left.visit(env).equals(BigDecimal.ZERO)) || !(right.visit(env).equals(BigDecimal.ZERO))) { 
            return BigDecimal.ONE;
        }
        else { 
            return BigDecimal.ZERO;
        }
    }
}

/* handling variable access */
class Var extends ExprNode {
    String id;

    Var(String id) {
        
        this.id = id;
    }

    BigDecimal visit(Env env) {
        return env.getVar(id);
    }

    public String toString() {
        return "(" + this.getClass().getSimpleName() + " " + this.id + ")";
    }

}

/* node for constants */
class Const extends ExprNode {
    BigDecimal value;

    Const(BigDecimal value) {
        
        this.value = value;
    }

    BigDecimal visit(Env env) {
        return this.value;
    }

    public String toString()
    {
        return "(" + this.getClass().getSimpleName() + " " + this.value.toString() + ")";
    }
}

/* node for calling functions */
class Func extends ExprNode {
    String name;
    /* a list of expressions provided to the function */
    ArrayList<ExprNode> args = new ArrayList<ExprNode>();

    Func(String name, ArrayList<ExprNode> args) {
        this.name = name;
        this.args = args;
    }

    BigDecimal visit(Env env) {
        if (!env.hasFunc(name)) {
            /* if the function name is not defined, exit immediately */
            System.err.println("Function " + name + " not defined.");
            System.exit(-1);
            return null;
        }
        else {
            // retrieve the function
            ASTFunc func = env.getFunc(name);
            // evaluate the args
            ArrayList<BigDecimal> inputs = new ArrayList<BigDecimal>();
            for (ExprNode arg : args) {
                inputs.add(arg.visit(env));
            }
            // make a call to the function
            return func.call(env, inputs);
        }
    }

    public String toString() {
        String str = "(Func<" + name + ">";
        for (ASTNode arg : this.args) {
            str = str + " " + arg;
        }
        return str + ")";
    }
}

class Str extends ASTNode implements Printable {
    String value;
    Str(String value) {
        //removing any leading or trailing quotes
        //quotes are forbidden from being in the body of strings, so this is valid
        this.value = value.replace("\"", "");
    }

    String visit(Env env) {
        return this.visit(env, true);
    }

    public String visit(Env env, boolean doPrint) {
        if (doPrint) {
            System.out.print(this.value);
        }
        return this.value;
    }

    public String toString()
    {
        return "(" + this.getClass().getSimpleName() + " " + this.value + ")";
    }
}

class Print extends ASTNode {
    // list of expressions/strings to print
    ArrayList<Printable> children = new ArrayList<Printable>();

    void add(Printable child) {
        if (child != null) {
            children.add(child);
        }
    }

    Object visit(Env env) {
        for (Printable child : children)
        {   
            try {
                // visit each argument without printing
                Object result = child.visit(env, false);
                if (result instanceof String) {
                    /* replacing '\n' with the actual newline */
                    result = ((String) (result)).replace("\\n", "\n");
                }
                System.out.print(result);
            }
            catch (KeywordExcept ex) {
                System.err.println(ex.getMessage());
                System.exit(-1);
            }
        }
        return null;
    }

    public String toString(){
        String str = "(" + this.getClass().getSimpleName();
        for (Printable child : this.children) {
            str = str + " " + child;
        }
        return str + ")";
    }
}

/* a block is simply a collection of statements, wrapped in { } */
class Block extends ASTNode {

    void add(ASTNode child) {
        if (child != null) 
            this.children.add(child);
    }

    Object visit(Env env) throws KeywordExcept{
        // simply visit each child
        for (ASTNode child : children)
        {
            child.visit(env);
        }
        return null;
    }
}

class IfElse extends ASTNode { 
    ExprNode cond;
    ASTNode ifNode;
    ASTNode elseNode;

    IfElse(ExprNode cond, ASTNode ifNode) {
        this.cond = cond;
        this.ifNode = ifNode;
        this.elseNode = null;
        children.add(cond);
        children.add(ifNode);
    }

    Object visit(Env env) throws KeywordExcept{
        // evaluate the condition
        BigDecimal result = cond.visit(env);
        if (result.equals(BigDecimal.ZERO))
        {
            //evaluate the else node (if provided)
            if (elseNode != null) {
               return this.elseNode.visit(env);
            }
            return BigDecimal.ZERO;
        }
        else {
            return this.ifNode.visit(env);
        }
    }

    void addElse(ASTNode elseNode) {
        this.elseNode = elseNode;
        this.children.add(elseNode);
    }
}

class While extends ASTNode {
    Expr cond;
    ASTNode body;
    While(ExprNode cond, ASTNode body) {
        this.cond = new Expr(cond);
        this.body = body;
        this.children.add(this.cond);
        this.children.add(body);
    }

    Object visit(Env env) throws KeywordExcept{
        while ( !(cond.visit(env, false).equals(BigDecimal.ZERO)) ) {
            try {
                body.visit(env);
            }
            catch (BreakExcept ex) {
                //catch a break by... breaking
                break;
            }
            catch (ContinueExcept ex) {
                //execution has already been halted for this iteration
                //so we can just move on along
            }
        }
        return null;
    }
}

class For extends ASTNode {
    Expr pre;
    Expr cond;
    Expr post;
    ASTNode body;
    For(ExprNode pre, ExprNode cond, ExprNode post, ASTNode body) {
        this.pre = new Expr(pre);
        this.cond = new Expr(cond);
        this.post = new Expr(post);
        this.body = body;
        this.children.add(this.pre);
        this.children.add(this.cond);
        this.children.add(this.post);
        this.children.add(this.body);
    }

    Object visit(Env env) throws KeywordExcept{
        /* first evaluate the pre expression */
        pre.visit(env, false);
        /* while the condition is true (not zero) */
        while ( !(cond.visit(env, false).equals(BigDecimal.ZERO)) ) {
            /* visit the body */
            try {
                body.visit(env);
            }
            catch (BreakExcept ex) {
                //if a break occurs, break
                break;
            }
            catch (ContinueExcept ex) {
                //execution has already been halted for this iteration
                //so we can just move on along
            }
            /* visit the post expression */
            post.visit(env, false);
        }
        return null;
    }
}


/* exception classes used for the keywords */
abstract class KeywordExcept extends Exception {
    KeywordExcept(String keyword, String place) {
        super("Error: " + keyword + " outside " + place);
    }
}

class BreakExcept extends KeywordExcept {
    BreakExcept() { super("Break", "a for/while"); }
}

class ContinueExcept extends KeywordExcept {
    ContinueExcept() { super("Continue", "a for/while"); }
}

class ReturnExcept extends KeywordExcept {
    BigDecimal retval;
    ReturnExcept(BigDecimal value) {
        super("Return", "of a function.");
        retval = value;
    }
}

class Break extends ASTNode {
    Object visit(Env env) throws KeywordExcept {
        /* throw an exception to try to break */
        throw new BreakExcept();
    }
}

class Continue extends ASTNode {
    Object visit(Env env) throws KeywordExcept {
        /* throw an exception to try to continue */
        throw new ContinueExcept();
    }
}

/* return from function */
class Return extends ASTNode {
    ExprNode child;
    Return(ExprNode child) {
        this.child = child;
        children.add(child);
    }

    Object visit(Env env) throws KeywordExcept {
        /* we start the return chain by throwing an exception */
        throw new ReturnExcept(child.visit(env));
    }
}

/* terminate the program */
class Halt extends ASTNode {
    Object visit(Env env) {
        System.exit(0);
        return null;
    }
}

/* function for storing and calling */
class ASTFunc {
    //name of function
    String name;
    //names of arguments
    ArrayList<String> args;
    //function body (a statement / block)
    ASTNode body;

    ASTFunc(String name, ArrayList<String> args, ASTNode body) {
        this.name = name;
        this.args = args;
        this.body = body;
    }

    public BigDecimal call(Env env, ArrayList<BigDecimal> input_args) {
        /* check that the provided args has the same count as the saved list */
        if (input_args.size() != args.size() ) {
            // exit if the args don't 
            System.err.println("Function received " + input_args.size() + " args, expected " + args.size());
            System.exit(-1);
        }
        // push new scope onto the Environment stack
        env.push();
        /* push each provided arg onto the new stack */
        for (int i = 0; i < args.size(); i++ ) {
            String name = args.get(i);
            BigDecimal value = input_args.get(i);
            env.locals().put(name, value);
        }
        // setting retval to zero (if no return occurs)
        BigDecimal retval = BigDecimal.ZERO;
        try {
            // visit the body
            this.body.visit(env);
        }
        catch (ReturnExcept ex) {
            // if a return occurs, we grab it
            retval = ex.retval;
        }
        catch (KeywordExcept ex) {
            // all other keywords that reach this level are considered errors
            System.err.println(ex.getMessage());
            System.exit(-1);
        }
        //if no exception occurs, then no return value specified
        // remove the locals from the Environment stack
        env.pop();
        return retval;
    }
}

/* quick and dirty classes to support built-in functions */
/* square root */
class Sqrt extends ASTFunc {
    Sqrt() {
        super("sqrt", null, null);
    }

    public BigDecimal call(Env env, ArrayList<BigDecimal> input_args) {
        if (input_args.size() != 1 ) {
            System.err.println("Function received " + input_args.size() + " args, expected " + 1);
            System.exit(-1);
        }
        return new BigDecimal(Math.sqrt(input_args.get(0).doubleValue()));
    }
}

/* sine */
class Sfunc extends ASTFunc {
    Sfunc() {
        super("s", null, null);
    }

    public BigDecimal call(Env env, ArrayList<BigDecimal> input_args) {
        if (input_args.size() != 1 ) {
            System.err.println("Function received " + input_args.size() + " args, expected " + 1);
            System.exit(-1);
        }
        return new BigDecimal(Math.sin(input_args.get(0).doubleValue()));
    }
}

/* cosine */
class Cfunc extends ASTFunc {
    Cfunc() {
        super("c", null, null);
    }

    public BigDecimal call(Env env, ArrayList<BigDecimal> input_args) {
        if (input_args.size() != 1 ) {
            System.err.println("Function received " + input_args.size() + " args, expected " + 1);
            System.exit(-1);
        }
         return new BigDecimal(Math.cos(input_args.get(0).doubleValue()));
    }
}

/* log */
class Lfunc extends ASTFunc {
    Lfunc() {
        super("l", null, null);
    }

    public BigDecimal call(Env env, ArrayList<BigDecimal> input_args) {
        if (input_args.size() != 1 ) {
            System.err.println("Function received " + input_args.size() + " args, expected " + 1);
            System.exit(-1);
        }
         return  new BigDecimal(Math.log(input_args.get(0).doubleValue()));
    }
}

/* exp */
class Efunc extends ASTFunc {
    Efunc() {
        super("e", null, null);
    }

    public BigDecimal call(Env env, ArrayList<BigDecimal> input_args) {
        if (input_args.size() != 1 ) {
            System.err.println("Function received " + input_args.size() + " args, expected " + 1);
            System.exit(-1);
        }
         return new BigDecimal(Math.exp(input_args.get(0).doubleValue())); 
    }
}

/* The environment represents the available scopes and functions */
class Env {
    //special variable scale (see README.md)
    int scale = 20;
    
    // stack of scopes 
    ArrayList<HashMap<String, BigDecimal>> stack = new ArrayList<HashMap<String, BigDecimal>>();
    
    // function dictionary
    HashMap<String, ASTFunc> functions = new HashMap<String, ASTFunc>();

    Env() {
        /* upon creation, add the global scope */
        this.push();
        /* put builtin functions into the dictionary */
        putFunc(new Sqrt());
        putFunc(new Sfunc());
        putFunc(new Cfunc());
        putFunc(new Lfunc());
        putFunc(new Efunc());
    }

    /* return the locals (topmost layer of the stack) */
    HashMap<String, BigDecimal> locals() {
        return stack.get(stack.size()-1);
    }

    /* return the globals (topmost layer of the stack) */
    HashMap<String, BigDecimal> globals() {
        return stack.get(0);
    }

    /* remove a scope */
    void pop() {
        stack.remove(stack.size()-1);

    }

    /* create a new scope */
    void push() {
        stack.add(new HashMap<String, BigDecimal>());
    }

    /* variable assignment and retrieval */
    boolean hasVar(String id) {
        if (locals().containsKey(id)) {
            return true;
        }
        return globals().containsKey(id);
    }

    BigDecimal getVar(String id) {
        // special case for variable scale
        if (id.equals("scale")) {
            return new BigDecimal(scale);
        }
        // check locals first
        if (locals().containsKey(id)) {
            return locals().get(id);
        }
        if (globals().containsKey(id)) {
            return globals().get(id);
        }
        // if value wasn't found, create it and put it in locals
        locals().put(id, BigDecimal.ZERO);
        return BigDecimal.ZERO;
    }
    void putVar(String id, BigDecimal value)
    {
        /* special case for special variable 'scale' */
        if (id.equals("scale")) {
            if (value.compareTo(BigDecimal.ZERO) == -1) {
                System.out.println("Cannot set scale to negative value");
                System.exit(-1);
            }
            scale = value.intValue();
        }
        //check if it's a local variable first
        if (locals().containsKey(id)) {
           locals().put(id, value);
        }
        //otherwise, we put it in globals
        else {
            globals().put(id, value);
        }
    }

    /* function definition and retrieval */
    boolean hasFunc(String name) {
        return functions.containsKey(name);
    }
    void putFunc(ASTFunc func) {
        functions.put(func.name, func);
    }
    ASTFunc getFunc(String name) {
        return functions.get(name);
    }
}

}

/* topmost rule - parses a list of statements / function definitions*/
file: 
    /* create a root node and environment */
    { Root root = new Root(); Env env = new Env(); }
    ( SEMI | ENDLINE | SEMI ENDLINE | P_COMMENT )* 
    /* handle the first statement */
    ( st=statement { root.add($st.an); } | def=define {  env.putFunc($def.f); })  
    ( ( SEMI | ENDLINE | SEMI ENDLINE | P_COMMENT )+ 
      /* handle all subsequent statements */
      ( ndef=define { env.putFunc($ndef.f); } | nxt=statement { root.add($nxt.an);} | EOF ))* EOF? 
    /* print the AST and evaluate it */
    {  System.err.println(root); root.visit(env); }
    ;

/* definitions are a 'define' keyword, an arglist, and a block */
define returns [ASTFunc f]:
    'define' name=ID args=arglist ENDLINE? bl=block 
    { $f = new ASTFunc($name.text, $args.args, $bl.bl); } /* build the AST function */
    ; 

/* an arglist is a list of comma separated identifiers */
arglist returns [ArrayList<String> args]:
     { ArrayList<String> lst = new ArrayList<String>(); $args = lst;}
    '(' (first=ID {lst.add($first.text);} (',' next=ID { lst.add($next.text); })* )? ')'
    ;

/* a statement is either an expression, a keyword, a string, or a block */
statement returns [ASTNode an]:
      e=expr   { $an= new Expr($e.en);} 
    | s=STRING { $an= new Str($s.text);}
    | 'print' { Print p = new Print(); $an = p; } 
               fp=printable { p.add($fp.pn); } 
               ( COMMA np=printable {p.add($np.pn);})*
    | bl=block { $an = $bl.bl; }
    | 'if' '(' con=expr ')'  ENDLINE? ifs=statement {IfElse ie = new IfElse($con.en, $ifs.an); $an = ie;}
      ('else' elses=statement { ie.addElse($elses.an);} )? {}
    | 'while' '(' cond=expr ')' ENDLINE? stat=statement { $an = new While($cond.en, $stat.an); }
    | 'for' '(' pre=expr SEMI cond=expr SEMI post=expr ')' ENDLINE? stat=statement{ $an = new For($pre.en, $cond.en, $post.en, $stat.an); }
    | 'break'    { $an = new Break(); }
    | 'continue' { $an = new Continue(); }
    | 'halt'     { $an = new Halt(); } /* end bc upon execution */
    | 'exit'     { System.exit(0); }   /* exit bc immediately */
    | 'return'   { ExprNode value = new Const(BigDecimal.ZERO); } ( value=expr {value = $value.en;})? { $an = new Return(value) ;} /* if no value is provided, return 0 */
    ;

/* a block is a list of statements inside { } */
block returns [Block bl]:
    { Block b = new Block(); $bl = b; } 
    '{' (SEMI | ENDLINE | SEMI ENDLINE )* ( fs=statement { b.add($fs.an); }  ((SEMI | ENDLINE | SEMI ENDLINE )* ns=statement {b.add($ns.an);}) *)? (SEMI | ENDLINE | SEMI ENDLINE )* '}' 
    ;

/* printables can be either expressions or strings */
printable returns [Printable pn]:
      e=expr { $pn = new Expr($e.en); }
    | s=STRING { $pn = new Str($s.text); }
    ;

/* all expressions */
expr returns [ExprNode en]:
      op='++' ID { $en = new PreInc($ID.text); }
    | op='--' ID { $en = new PreDec($ID.text); }
    | ID op='++' { $en = new PostInc($ID.text); }
    | ID op='--' { $en = new PostDec($ID.text); }
    | op='-' e=expr { $en = new Negate($e.en); }
    | <assoc=right> el=expr op='^' er=expr { $en = new Power($el.en, $er.en); }
    | el=expr op=('*'|'/') er=expr { $en=($op.text.equals("*")) ? new Mul($el.en, $er.en) : new Div($el.en, $er.en); }
    | el=expr op=('+'|'-') er=expr { $en=($op.text.equals("+")) ? new Add($el.en, $er.en) : new Sub($el.en, $er.en); }
    /* assignment */
    | ID '=' e=expr { $en = new Assign($ID.text, $e.en); }
    /* relational expressions */
    | el=expr '<'  er=expr { $en = new Lt($el.en, $er.en); }
    | el=expr '<=' er=expr { $en = new Le($el.en, $er.en); }
    | el=expr '>'  er=expr { $en = new Gt($el.en, $er.en); }
    | el=expr '>=' er=expr { $en = new Ge($el.en, $er.en); }
    | el=expr '==' er=expr { $en = new Eq($el.en, $er.en); }
    | el=expr '!=' er=expr { $en = new NotEq($el.en, $er.en); }
    /* boolean expressions */
    | '!' expr { $en = new Not($expr.en); }
    | el=expr op='&&' er=expr { $en = new And($el.en, $er.en); }
    | el=expr op='||' er=expr { $en = new Or($el.en, $er.en); }
    | FLOAT { $en = new Const(new BigDecimal($FLOAT.text)); }
    | func  { $en = $func.en; }
    | ID    { $en = new Var($ID.text); }
    | '(' e=expr ')' { $en = $e.en; } 
    ;

/* function calling (where args may be a list of expressions) */
func returns [ExprNode en] :
    ID '(' { ArrayList<ExprNode> args = new ArrayList<ExprNode>(); $en = new Func($ID.text, args);} (arg=expr  {args.add($arg.en); } (',' next=expr {args.add($next.en); })*)? ')'
    ;

/* Lexer rules */
ID: [_A-Za-z]+;
FLOAT: [0-9]*[.]?[0-9]+; 
STRING: ["].*?["]; /* lazy definition of string */
WS : [ \t]+ -> skip ;
C_COMMENT: [/][*](.)*?[*][/] -> skip;
P_COMMENT: '#' (.)*? ENDLINE;
ENDLINE: '\r'?'\n';
SEMI: ';';
COMMA: ',';