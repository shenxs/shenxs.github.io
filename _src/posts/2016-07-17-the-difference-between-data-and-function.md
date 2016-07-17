    Title: The difference between data and function
    Date: 2016-07-17T17:05:26
    Tags: sicp,scheme,racket,体会;



<!-- more -->

其实我想说有时候过程和数据并没有什么区别(sometime)

**例如**
```racket
(define A (cons 1 (cons 2 (cons 3))))
```
定义了一个`list`

你会把`A`看作是一个数据,他里面放着一些数字,1 2 3

如果我们自己来实现`cons`,`frist`(or `car`),`rest`(or `cdr`).
我们也许会使用如下的定义

```racket
(define-struct pair [left right])
(define our_cons? pair?)
(define (our_cons a_value a_list)
  (cond
    [(empty? a_list) (make-pair a_value a_list)]
    [(our_cons? a_list) (make-pair a_value a_list)]
    [else (error "第二个参数应该是一个list")]))

(define (our_first a_list)
  (cond
    [(empty? a_list) (error 'a_list "不能为空")]
    [else (pair-left a_list)]))

(define (our_rest a_list)
  (cond
    [(empty? a_list) (error 'a_list "不能为空")]
    [else (pair-right a_list)]))
```

以上数据就是数据,`our_first`,`our_rest`,`our_cons`都是动作,这些函数所产生的就是数据

我们来看另一种实现

```racket
(define (my_cons x y)
  (λ (choose)
     (cond
       [(= choose 1) x]
       [else y])))


(define (my_first a_list)
  (a_list 1))
(define (my_rest a_list)
  (a_list 2))
```
这里就不一样了,你以为
```racket
(my_cons 'a 'b)
```
会的到一个数据,实际上他返回的是一个函数(也就是说是一个过程)

`first`和`rest`的设计也更加的奇特,将这个过程应用不同的值,就分别取了first和rest部分

在这里数据和函数被混淆了,数据真的是数据吗?数据和一个过程的区别在哪里?
第二个版本的实现也确实更加的优雅
