#lang scribble/manual

Title: 操作对象
Date: 2018-08-28T14:16:32
Tags: scheme

@(require (for-label racket))
@(require scribble/eval)

@(define (cpt b text)
    @list{@bold[b] : @italic[text] })
@(define (stx text)
   @cpt["语法" text])
@(define (rtn text)
   @cpt["返回" text])

介绍一些对象上的操作,包括lists, numbers, characters, strings, vectors, bytevectors, symbols, booleans, hashtables, 以及 enumerations

<!-- more -->


@section[#:style 'unnumbered]{常量和引用}

@stx{constant}

@rtn{constant}

@italic{constant} 是可以自我解释的一些常量,例如数字,布尔值,字符,字符串或者二进制向量.常量是不可改变的

@interaction[
    3.2
    #f
    #\c
    "hi"
    #(3 4 5)
]


@stx{(quote obj)}

@stx{ }@racket['obj]

@rtn{obj}

@italic{@racket['obj]} 是等价于@racket{(quote obj)}的。这种缩写会被scheme的reader自动转换为更长的形式。

@smaller{qoute} 禁止对于普通的@italic{obj}进行解析，这使得@italic{obj}可以像数据一样被使用。尽管所有的scheme的对象都可以被引用，但是对于常量的引用是没有必要的。比如，数字，布尔值，字符，字符串以及二进制向量。

被引用和自解析的常量是不可以被修改的。也就是说不可以通过@racket{set-car!},@racket{string-set!}之类的操作修改一个常量。scheme的实现需要保证在这种操作试图运行的时候抛出异常。如果这种对于不可修改的常量的修改没有被侦测到，那么其后果是不确定的。scheme的实现可以在不同的常量之间共用存储来节省空间。

@interaction[
  (+ 2 3)
  '(+ 2 3)
  'a
  'cons
  '()
  '7
]

@stx{(quasiquote obj ...)}

@stx{@racket[`obj]}

@stx{(unquote obj ...)}

@stx{,obj}

@stx{(unquote-splicing obj ...)}

@stx{@",@obj"}

@rtn{见下文}

这六者之间是有一一对应的等价关系的。都会在scheme的reader中被转换。
@racket[quasiquote]和@racket[quote]是非常类似的,除了它允许部分被引用的对象被去引用.在@racket[quasiquote]中允许存在@racket[unquote]以及@racket[unquote-splicing]的子表达式被解析,但是其他所有的都还是被引用的(不会被求值)
每一个@racket[unquote]的表达式都会被求值然后返回值作为@racket[unquote]的中的值.
每一个@racket[unquote-splicing]的子表达式的求值结果会和外面的list或者vector拼接起来.
@racket[unquote]以及@racket[unquote-splicing]只可以在@racket[quasiquote]中使用.

@racket[quasiquote]有可能是嵌套的,每个quasiquote都会引入一层新的引用,然后每一层unquote以及unquote-splicing都会去掉一层引用.
所以一个被嵌套了n层的quasiquote表达式必须要去引用n次.


@interaction[
 `(+ 1 1)
 `(+ 2 ,(* 3 4))
 `(a b (,(+ 2 3) c) d)
 `(a b ,(reverse '(c d e)) f g)
 (let ([a 1] [b 2])
   `(,a . ,b))

 `(+ ,@(cdr '(* 2 3)))
 `(a b ,@(reverse '(c d e)) f g)
 (let ([a 1] [b 2])
  `(,a ,@b))
 `#(,@(list 1 2 3))
 '`,(cons 'a 'b)
 `',(cons 'a 'b)
 ]

@interaction[
 `(a (unquote) b)
 `(a (unquote (+ 3 3)) b)
 `(a (unquote (+ 3 3) (* 6 6)) b)

 (let ([x '(m n)]) ``(a ,@,@x f))
 (let ([x '(m n)])
   (eval `(let ([m '(b c)] [n '(d e)]) `(a ,@,@x f))
        (make-base-namespace)))
 ]

可以吧unquote和unquote-splicing当做quasiquote的辅助关键词.
在他们被视作辅助关键词的上下文环境中单独是一种语法错误









