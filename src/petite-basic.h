////////////////////////////////// ABOUT.TXT ///////////////////////////////////
/******************************************************************************\
        ABOUT:   Petite Basic interpreter made in C, with only stdc libs
        MOD:     Modded for the PETITE-8
        AUTHOR:  Lunaryss, 2025
        LICENSE: Public Domain, no warranty given, use at your own risk
        VERSION: Beta 0.2
\******************************************************************************/



//////////////////////////////// PETITE-BASIC.H ////////////////////////////////
#ifndef PETITE_BASIC_H
#define PETITE_BASIC_H

// constants
#define PB_VAR_NAME_LEN  10
#define PB_MEMORY_SIZE   256
#define PB_VARS_COUNT    64
#define PB_CODE_LEN      4096
#define PB_STACK_SIZE    8
#define PB_BITMAPS_COUNT 16

// petite basic value
typedef
  unsigned char
  pb_value;

// variable type
typedef
  struct {
    char     name[PB_VAR_NAME_LEN + 1];
    pb_value addr;
  }
  pb_var;

// statement type
typedef struct {
  char*  name;
  void (*func)(char*, char);
} pb_cmd;

// variables
extern pb_value* pb_mem;
extern pb_var*   pb_vars;
extern pb_cmd    pb_cmds[];
extern char*     pb_code;
extern char      pb_pause;

// functions
void     pb_init();
void     pb_prep();
void     pb_exec();
void     pb_kill();
void     pb_line(char* line, char len);
pb_value pb_expr(char* expr, char len);
void     pb_goto(char* label, char len);
pb_value pb_get(char* name, char len);
void     pb_set(char* name, char len, pb_value value);

// petite_basic_h
#endif



///////////////////////////// PETITE-BASIC-LOCAL.H /////////////////////////////
#if defined PETITE_BASIC_C || defined PETITE_BASIC_COMMANDS_C

// importing count of commands
extern const int pb_cmds_count;

// initializing vars
extern int   pb_mem_ptr;
extern char* pb_ptr;
extern char* pb_call_stack[PB_STACK_SIZE];
extern char  pb_call_ptr;

// data list
unsigned char* pb_bitmaps;

// PETITE_BASIC_LOCAL_H
#endif



/////////////////////////// PETITE-BASIC-COMMANDS.H ////////////////////////////
#ifdef PETITE_BASIC_COMMANDS_C

// include libs
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// to the form
#define pb_cmd_goto pb_goto

// utility to parse arguments
void pb_parse_args(char* args, char len, pb_value* out, char count);

// all statements
void pb_cmd_if(char*, char);
void pb_cmd_rem(char*, char);
void pb_cmd_let(char*, char);
void pb_cmd_call(char*, char);
void pb_cmd_return(char*, char);
void pb_cmd_peek(char*, char);
void pb_cmd_poke(char*, char);

// modded
void pb_cmd_rect(char*, char);
void pb_cmd_frame(char*, char);
void pb_cmd_bitmap(char*, char);
void pb_cmd_sprite(char*, char);

// list with all the statements
pb_cmd pb_cmds[] = {
  { "if",     &pb_cmd_if },
  { "rem",    &pb_cmd_rem },
  { "let",    &pb_cmd_let },
  { "goto",   &pb_cmd_goto },
  { "call",   &pb_cmd_call },
  { "return", &pb_cmd_return },
  { "peek",   &pb_cmd_peek },
  { "poke",   &pb_cmd_poke },
  { "rect",   &pb_cmd_rect },
  { "frame",  &pb_cmd_frame },
  { "bitmap", &pb_cmd_bitmap },
  { "sprite", &pb_cmd_sprite },
};

// setting the size of the pb_cmds
const int pb_cmds_count =
  sizeof(pb_cmds) / sizeof(pb_cmd);

// this command does nothing
void pb_cmd_rem(char* args, char len) { }

// if command
void pb_cmd_if(char* args, char len)
{
  // getting the condition
  char colon = strchr(args, ':') - args;
  char comma = strchr(args + colon, ',') - args;
  char condlen = colon;
  char thenlen = comma - colon - 1;
  char elselen = len - comma - 1;

  // evaluating the condition
  pb_value cond = pb_expr(args, condlen);

  // going to the then or else
  if (cond != 0)
    pb_goto(args + colon + 1, thenlen);
  else
    pb_goto(args + comma + 1, elselen);
}

// defining a variable
void pb_cmd_let(char* args, char len) {
  char sep = strchr(args, ':') - args;
  pb_set(args, sep, pb_expr(args + sep + 1, len - sep - 1));
}

// getting a value from memory
void pb_cmd_peek(char* args, char len) {
  char sep = strchr(args, ',') - args;
  pb_value val = pb_mem[pb_expr(args + sep + 1, len - sep - 1)];
  pb_set(args, sep, val);
}

// setting a value to memory
void pb_cmd_poke(char* args, char len) {
  char sep = strchr(args, ',') - args;
  pb_mem[pb_expr(args + sep + 1, len - sep - 1)] = pb_expr(args, sep);
}

// calling a label
void pb_cmd_call(char* args, char len) {
  pb_call_stack[pb_call_ptr++] = strchr(pb_ptr, '\n') + 1;
  pb_goto(args, len);
}

// returning from a function
void pb_cmd_return(char* args, char len) {
  pb_ptr = pb_call_stack[--pb_call_ptr] - 1;
}

// drawing a frame
void pb_cmd_frame(char* args, char len) {
  pb_pause = 1;
}

// filling a rectangle
void pb_cmd_rect(char* args, char len)
{  
  // arguments
  pb_value list[5];
  pb_parse_args(args, len, list, 5);

  // drawing the rectangle
  for (int x = list[0]; x < list[2] + list[0]; x++)
    for (int y = list[1]; y < list[3] + list[1]; y++)
      win_pixel(x, y, list[4]);
}

// loading a bitmap
void pb_cmd_bitmap(char* args, char len)
{
  // getting the arguments
  char sep = strchr(args, ':') - args;
  pb_value datano = pb_expr(args, sep);
  char length = 0;
  
  // reading the data
  for (int i = sep + 1; i < len; i++)
    if (args[i] == '1' || args[i] == '0')
      pb_bitmaps[datano * 26 + ++length] = args[i];

  // setting the len to the data
  pb_bitmaps[datano * 26] = length;
}

// drawing a sprite
void pb_cmd_sprite(char* args, char len)
{
  // arguments
  pb_value list[4];
  pb_parse_args(args, len, list, 4);

  // getting the width of the bitmap
  char size = pb_bitmaps[list[0] * 26] == 25 ? 5 : 4;

  // drawing the sprite
  for (int x = list[1]; x < list[1] + size; x++)
    for (int y = list[2]; y < list[2] + size; y++)
      if (pb_bitmaps[list[0] * 26 + x - list[1] + (y - list[2]) * size + 1] == '1') 
        win_pixel(x, y, list[3]);
}

// utility to parse arguments
void pb_parse_args(char* args, char len, pb_value* out, char count)
{
  // getting all the arguments
  char* strs[9] = {0};
  strs[0] = args;
  strs[count] = args + len + 1;

  // getting the arguments
  for (int i = 0; i < count - 1; i++)
    strs[i + 1] = strchr(strs[i], ',') + 1;

  // calculating the arguments
  for (int i = 0; i < count; i++)
    out[i] = pb_expr(strs[i], strs[i + 1] - strs[i] - 1);
}

// petite_basic_commands_h
#endif



//////////////////////////////// PETITE-BASIC.C ////////////////////////////////
#ifdef PETITE_BASIC_C

// include libs
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// enum of priority levels
enum {
  PB_PRIO_CMP,
  PB_PRIO_ADD,
  PB_PRIO_MUL,
  PB_PRIO_GRP, 
  PB_PRIO_LIT,
};

// initializing vars
pb_value* pb_mem;
int       pb_mem_ptr = 0;
pb_var*   pb_vars;
char*     pb_code;
char*     pb_ptr = 0;
char      pb_pause = 0;
char*     pb_call_stack[PB_STACK_SIZE] = {0};
char      pb_call_ptr = 0;

// trimming a string
char* pb_trim(char* str, char* len) {
  while (*str == ' ')
    str++, len[0]--;
  while (*(str + *len - 1) == ' ' && *len > 0)
    len[0]--;
  return str;
}

// getting value of the variable
pb_value pb_get(char* name, char len)
{
  // new position of the variable
  int var = -1;

  // do exist
  for (int i = 0; i < PB_VARS_COUNT; i++)
    if (strncmp(name, pb_vars[i].name, len) == 0)
      var = i;

  // return the value
  if (var != -1)
    return pb_mem[pb_vars[var].addr];
}

// setting a value to a variable
void pb_set(char* name, char len, pb_value value)
{
  // new position of the variable
  int var = pb_mem_ptr;
  name = pb_trim(name, &len);

  // do already exist
  for (int i = 0; i < PB_VARS_COUNT; i++)
    if (strncmp(name, pb_vars[i].name, len) == 0)
      var = i;
  
  // new variable, allocating and naming
  if (var == pb_mem_ptr) {
    memcpy(pb_vars[var].name, name, len);
    pb_vars[var].addr = pb_mem_ptr;
    pb_mem_ptr++;
  }

  // setting the value
  pb_mem[pb_vars[var].addr] = value;
}

// going to the label
void pb_goto(char* label, char len)
{
  // trimming the label
  label = pb_trim(label, &len);

  // if label is $
  if (label[0] == '$' && len == 1)
    return;

  // actually going to the label
  for (int i = 0; i < PB_CODE_LEN - len - 1; i++) 
    if (pb_code[i + len] == ':' && strncmp(pb_code + i, label, len) == 0)
      pb_ptr = i + pb_code - 1;
}

// interpreting the expression
pb_value pb_expr(char* expr, char len)
{
  // trimming
  expr = pb_trim(expr, &len);

  // position of the operator
  char oper = 0;
  char prio = PB_PRIO_LIT;

  // scaning for the lowest priority operator
  for (char i = 0; i < len; i++)
  {
    // comparision operators
    if (expr[i] == '=' || expr[i] == '<' || expr[i] == '>')
      oper = i, prio = PB_PRIO_CMP;

    // additive operators
    if ((expr[i] == '+' || expr[i] == '-') && prio >= PB_PRIO_ADD)
      oper = i, prio = PB_PRIO_ADD;
    
    // multiplicative operators
    else if ((expr[i] == '*' || expr[i] == '/') && prio >= PB_PRIO_MUL)
      oper = i, prio = PB_PRIO_MUL;

    // grouping and function calls
    else if (expr[i] == '(' && prio >= PB_PRIO_GRP)
      oper = i, prio = PB_PRIO_GRP;

    // skipping the parenthesis
    if (expr[i] == '(') {
      char nesting = 1;
      while (nesting > 0)
        if (expr[++i] == '(')
          nesting++;
        else if (expr[i] == ')')
          nesting--;
    }
  }
  
  // in case of no operator found
  if (prio == PB_PRIO_LIT)
  {
    // the value is the number
    if (expr[0] >= '0' && expr[0] <= '9')
      return atoi(expr);
    
    // the value is variable
    return pb_get(expr, len);
  }

  // operator is binary
  else if (prio >= PB_PRIO_CMP && prio <= PB_PRIO_MUL)
  {
    // computing the operands
    pb_value a = pb_expr(expr, oper);
    pb_value b = pb_expr(expr + oper + 1, len - oper - 1);

    // computing the result
    switch (expr[oper]) {
      case '=': return a == b;
      case '<': return a < b;
      case '>': return a > b;
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return a / b;
    }
  }

  // operator is grouping
  else if (oper == 0)
    return pb_expr(expr + 1, len - 2);
}

// interpreting a line
void pb_line(char* line, char len)
{
  // trimming and getting the start position
  line = pb_trim(line, &len);
  char* start = line;

  // skipping if ends with : or empty
  if (line[len - 1] == ':' && line[len - 2] != '\\' || len <= 0)
    return;

  // lowercasing the line
  for (char i = 0; i < len; i++)
    line[i] =
      line[i] >= 'A' && line[i] <= 'Z'
        ? line[i] + 32
        : line[i];

  // length of command and function to call
  char cmdlen =
    strchr(line, ' ') - line < len
      ? strchr(line, ' ') - line
      : len;
  void (*func)(char*, char) = 0;

  // look for the statement
  for (char i = 0; i < pb_cmds_count; i++)
    if (strncmp(line, pb_cmds[i].name, cmdlen) == 0)
      func = pb_cmds[i].func;

  // calling the function
  if (func)
    func(line + cmdlen + 1, len - cmdlen - 1 - (start - line));
}

// initializing the interpreter
void pb_init() {
  pb_mem  = malloc(PB_MEMORY_SIZE);
  pb_code = malloc(PB_CODE_LEN);
  pb_vars = malloc(PB_VARS_COUNT * sizeof(pb_var));
  pb_bitmaps = malloc(PB_BITMAPS_COUNT * 26);
}

// parsing the code
void pb_prep()
{
  // setting the pointer
  pb_ptr = pb_code;
  
  // removing carriage return
  for (char* ptr = pb_ptr; *ptr != '\0'; ptr++)
    *ptr = *ptr == '\r' || *ptr == '\t' ? ' ' : *ptr;
}

// interpret the sequence of commands
void pb_exec()
{
  // beggining of the line
  char* line = pb_ptr;

  // resetting the pause
  pb_pause = 0;

  // looping through all lines
  while (*line != '\0' && !pb_pause)
    if (*pb_ptr == '\n' || *pb_ptr == '\0')
      pb_line(line, pb_ptr - line),
      line = ++pb_ptr;
    else
      pb_ptr++;
}

// killing the interpreter
void pb_kill() {
  free(pb_mem);
  free(pb_code);
  free(pb_vars);
  free(pb_bitmaps);
}

// petite_basic_c
#endif