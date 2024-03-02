#ifndef ERRLIST_H_
#define ERRLIST_H_

#define LEXEME_ERROR 'A'
#define SYNTAX_ERROR 'B'

enum SyntaxErr {
    ILLEGAL_CHARSET = LEXEME_ERROR,
    ILLEGAL_HEX     = LEXEME_ERROR,
    ILLEGAL_CHAR    = LEXEME_ERROR,
    ILLEGAL_ID      = LEXEME_ERROR,
    ILLEGAL_OP      = LEXEME_ERROR,
    MISSING_SEMI    = SYNTAX_ERROR,
    MISSING_CLOSING = SYNTAX_ERROR,
    DEF_AFTER_STMT  = SYNTAX_ERROR,
};

enum SemanticErr
{
    UNDEF_VAR = 1, // exp: variable is used without definition
    UNDEF_FUNC,    // exp: function is invoked without definition
    REDEF_VAR,     // def: variable is redefined
    REDEF_FUNC,    // def: function is redefined
    UNMATCH_TYPE,  // exp: unmatching types on both sides of assignment operator
    ASSIGN_RVAL,   // ass: rvalue on the left side of assignment operator
    UNMATCH_OP,    // exp: unmatching operands, such as adding an integer to a structure variable
    UNMATCH_RET,   // ret: unmatching return type
    UNMATCH_ARG,   // exp: the function’s arguments mismatch the declared parameters (either types or numbers, or both)
    NON_ARRAY,     // exp: the variable is not an array
    NON_FUNC,      // exp: the variable is not a function
    NON_IDX,       // exp: the index is not an integer
    NON_STRUCT,    // exp: the variable is not a structure
    NON_MEMBER,    // exp: the member is not a member of the structure
    REDEF_STRUCT,  // def: the structure is redefined
    UNDEF_STRUCT,
};

#endif