    Title: Racket ffi
    Date: 2016-07-18T16:28:29
    Tags: Racket,FFI,

   _今天花了些时间了解了Racket的FFI用法,只是初步的了解.所谓的*FFI*是指 *foreign fuction interface*.ok FFI让racket程序可以调用基于c的api而不用去写一行的c.

<!-- more -->

  以下内容大部分来自对于这篇[文章](http://prl.ccs.neu.edu/blog/2016/06/27/tutorial-using-racket-s-ffi/)的翻译,当然不会全是完全一样,其实我也有自己的私心---学好一样东西最好的办法就是将他教授给别人.

  学习FFI最好的方式是去看[文档](http://docs.racket-lang.org/foreign/index.html).但是对于一个初学者来说文档的信息量可能太大.

  这篇教程会手把手地教会你关于FFI的一些使用,你需要准备的就是在你的电脑上安装好`Drracket`.

  在开始之前,先声明一件事情.感谢`Eli Barzilay`和`Dmitry Orlovsky`的工作让我们可以在racket中使用FFI.如果你对于FFI的设计实现好奇的话可以参考这篇[论文](http://www.ccs.neu.edu/racket/pubs/scheme04-bo.pdf).

  这篇教程主要会使用 [Cairo](https://www.cairographics.org/)图形库,主要是因为它是和Racket一起捆绑安装的.

  我们的目标就是用racket复刻Cairo官网上的样例

```c
  cairo_move_to (cr, 50.0, 75.0);
  cairo_line_to (cr, 200.0, 75.0);

  cairo_move_to (cr, 50.0, 125.0);
  cairo_line_to (cr, 200.0, 125.0);

  cairo_move_to (cr, 50.0, 175.0);
  cairo_line_to (cr, 200.0, 175.0);

  cairo_set_line_width (cr, 30.0);
  cairo_set_line_cap (cr, CAIRO_LINE_CAP_ROUND);
  cairo_stroke (cr);

```


为了实现上述c代码所具有的功能,我们需要做一些准备工作.

```racket
#lang racket
(require racket/draw)
(define bt (make-bitmap 256 256))
(define bt-surface (send bt get-handle))
```

首先需要导入FFI

```racket
(require ffi/unsafe)
```

接下来就是导入Cairo库了


```racket
(define cairo-lib (ffi "libcairo"))
```


## 提取函数

在cairo的链接库中存在这样的api接口


```c
/* NB: this is C code */
cairo_t * cairo_create (cairo_surface_t *target);
```

现在就可以用ffi将cairo_create转换为racket的函数,让我们可以在racket调用


```racket
(define cairo-create
    (get-ffi-obj "cairo_create" cairo-lib
                 (_fun _pointer -> _pointer)))
```

`get-ffi-obj`拿到函数的名字和它所在的库就可以拿到这个函数了,但是并不知道这个函数的调用参数.最后的那部分就是说明`cairo_create`的参数和返回值的  `->` 的作用只是分隔参数的返回值

到这里对于ffi就有一个大致的了解了
`_pointer`是导入FFI之后就可使用的,对应的是c中的指针,类似的基本数据类型都有对应,例如_int
,_double等等.
只有`_pointer`类型的话也带来了一个问题,你很容易将不同的指针类型搞混,毕竟™都是指针.

## 插曲 类型安全

先定义一下指针类型,再去使用他们
```racket
(define-cpointer-type _cairo_t)
(define-cpointer-type _cairo_surface_t)
```

用新的指针类型来定义`cairo_create`

```racket
(define cairo-create
    (get-ffi-obj "cairo_create" cairo-lib
                 (_fun _cairo_surface_t -> _cairo_t)))
```


## 使用宏来减少重复劳动

有了上面的经验,接下来就可以实现其他的函数,将我们要用到的函数通通转化到Racket可以调用的形式


```c
void cairo_move_to (cairo_t *cr, double x, double y);
void cairo_line_to (cairo_t *cr, double x, double y);
void cairo_set_line_width (cairo_t *cr, double width);
void cairo_set_line_cap (cairo_t *cr, cairo_line_cap_t line_cap);
void cairo_stroke (cairo_t *cr);
```
那么就从 `cairo_move_to`下手好了,就像之前那么做

```racket
(define cairo-move-to
    (get-ffi-obj
     "cairo_move_to"
     cairo-lib
     (_fun _pointer _double _double -> _void)))
```
似乎每次都要写一遍 (get-ffi-obj xxx cairo-lib (...)),实际上ffi提供了`define-ffi-definer`来简化函数的定义

```racket
 require ffi/unsafe/define)
 (define-ffi-definer define-cairo cairo-lib)
 (define-cairo cairo-move-to
     (_fun _cairo_t _double _double -> _void)
        #:c-id cairo_move_to)
```
如果你喜欢原来的函数名子的话定义还可以更加简单


```racket
(define-cairo cairo_move_to (_fun _cairo_t _double _double -> _void))
```


接下啦如法炮制

```racket
(define-cairo cairo-line-to
    (_fun _cairo_t _double _double -> _void)
    #:c-id cairo_line_to)
(define-cairo cairo-set-line-width
    (_fun _cairo_t _double -> _void)
    #:c-id cairo_set_line_width)
(define-cairo cairo-stroke
    (_fun _cairo_t -> _void)
    #:c-id cairo_stroke)
```


比较有意思的是`cairo_set_line_cap`,它的参数中出现了`cairo_line_cap_t`,这是一个枚举对象.Rackt的FFI可以让你方便的定义枚举对象

```racket
(define _cairo_line_cap_t
    (_enum '(butt round square)))
'))
```

这里的符号并不重要,因为他们会与一个整数对应(其实我不太明白,也许枚举类型会有一个编号,这些符号最终也只是这些编号的助记符).有了这个枚举类那么`cairo_set_line_cap`也就可以轻松的定义出来了




```racket

(define-cairo cairo-set-line-cap
    (_fun _cairo_t _cairo_line_cap_t -> _void)
    #:c-id cairo_set_line_cap)
```

## ok,看看我们都完成了些什么

```racket
(cairo-move-to ctx 50.0 75.0)
(cairo-line-to ctx 200.0 75.0)
 
(cairo-move-to ctx 50.0 125.0)
(cairo-line-to ctx 200.0 125.0)
 
(cairo-move-to ctx 50.0 175.0)
(cairo-line-to ctx 200.0 175.0)
 
(cairo-set-line-width ctx 30.0)
(cairo-set-line-cap ctx 'round)
(cairo-stroke ctx)')
```

在这里我们用cairo的函数库已经绘制到bt中了,now看看结果吧

```racket
(require pict)
(linewidth 2 (frame (bitmap bt)))
```

没有什么意外的话会看到
![](/img/pict.png)

现在将完整的代码放在下面

```racket
#lang racket
(require racket/draw
         racket/gui/base
         ffi/unsafe
         ffi/unsafe/define
         pict)

(define bt (make-bitmap 256 256))
(define bt-surface (send bt get-handle))
(define-cpointer-type _cairo_t)
(define-cpointer-type _cairo_surface_t)
(define cairo-lib (ffi-lib "libcairo"))
(define cairo-create (get-ffi-obj "cairo_create" cairo-lib
                                  (_fun  _cairo_surface_t -> _cairo_t)))
(define-ffi-definer define-cairo cairo-lib)

(define-cairo cairo-move-to
  (_fun _cairo_t _double _double -> _void)
  #:c-id cairo_move_to)
(define-cairo cairo-line-to
  (_fun _cairo_t _double _double -> _void)
  #:c-id cairo_line_to)
(define-cairo cairo-set-line-width
  (_fun _cairo_t _double -> _void)
  #:c-id cairo_set_line_width)
(define-cairo cairo-stroke
  (_fun _cairo_t -> _void)
  #:c-id cairo_stroke)

(define _cairo_line_cap_t
  (_enum '(butt round square)))

(define-cairo cairo-set-line-cap
  (_fun _cairo_t _cairo_line_cap_t -> _void)
  #:c-id cairo_set_line_cap)

(define ctx (cairo-create bt-surface))
(cairo-move-to ctx 50.0 75.0)
(cairo-line-to ctx 200.0 75.0)
(cairo-move-to ctx 50.0 125.0)
(cairo-line-to ctx 200.0 125.0)
(cairo-move-to ctx 50.0 175.0)
(cairo-line-to ctx 200.0 175.0)
(cairo-set-line-width ctx 30.0)
(cairo-set-line-cap ctx 'round)
(cairo-stroke ctx)

(linewidth 2 (frame (bitmap bt)))')'))
```
ok了,第一部分就这样.

