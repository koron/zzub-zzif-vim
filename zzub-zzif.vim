scriptencoding utf-8

let s:map = { 'fizz': 'F', 'buzz': 'B', 'fizzbuzz': 'Z' }
let s:unit = 'AAFABFAAFBAFAAZ'

" fizzbuzzの数を求める
function! s:CountFizzbuzz(inList)
  return len(filter(copy(a:inList), 'v:val ==# "fizzbuzz"'))
endfunction

" 探索用の正規表現を決定する
function! s:GetPattern(inList)
  return join(map(copy(a:inList), 'get(s:map, v:val)'), 'A\{-}')
endfunction

function! s:GetMinLen(inList)
  return len(filter(copy(a:inList), 'has_key(s:map, v:val)'))
endfunction

function! ZzubZzif(inList)
  " 探索空間を作成する
  let field = repeat(s:unit, s:CountFizzbuzz(a:inList) + 1)

  " 探索用のパターンを生成する。パターンが空なら探索するのは無駄
  let pattern = s:GetPattern(a:inList)
  if strlen(pattern) == 0
    return []
  endif

  " 不要な探索を打ち切るために最短長を求めておく
  let minLen = s:GetMinLen(a:inList)

  " 最短解を求めるために暫定解の保存場所
  let match_start = -1
  let match_len = 0

  let index = 0
  while index < strlen(field)
    " パターンにマッチする部分文字列を探す。なければ探索終了
    let m = matchstr(field, pattern, index)
    if strlen(m) <= 0
      break
    endif

    " 見つかった部分文字列が暫定解よりも短い場合は、そちらを暫定解とする
    if match_len == 0 || strlen(m) < match_len
      let match_start = stridx(field, m, index)
      let match_len = strlen(m)
      " 理論上の最短解を見つけた場合はそこで探索を終了する
      if match_len == minLen
	break
      endif
    endif

    " より短いを求めて次の文字から探索を再開(ループ)する
    let index += 1
  endwhile

  " 解が見つかっていればそれを整形して、なければ空リストを返す
  if match_start >= 0 && match_len >= 1
    return [match_start + 1, match_start + match_len]
  else
    return []
  endif
endfunction

let s:error = 0

function! s:TestOne(queryList, expectedList)
  let actualList = ZzubZzif(a:queryList)
  if actualList != a:expectedList
    echo string(a:queryList).' -> '.string(actualList)
	  \.' (expected '.string(a:expectedList).')'
    let s:error += 1
  endif
endfunction

function! s:TestAll()
  call s:TestOne(['fizz'], [3, 3])
  call s:TestOne(['buzz'], [5, 5])
  call s:TestOne(['fizz', 'buzz'], [9, 10])
  call s:TestOne(['buzz', 'fizz'], [5, 6])
  call s:TestOne(['fizz', 'fizz'], [6, 9])
  call s:TestOne(['fizz', 'fizz', 'buzz'], [6, 10])
  call s:TestOne(['fizz', 'buzz', 'fizz'], [3, 6])
  call s:TestOne(['fizzbuzz', 'fizz'], [15, 18])
  call s:TestOne(['buzz', 'buzz'], [])
  if s:error == 0
    echo 'Pass all tests'
  endif
endfunction

call s:TestAll()

" vim:set ts=8 sts=2 sw=2 tw=0:
