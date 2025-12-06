#let cyrill = (
  0x410,
  0x411,
  0x412,
  0x413,
  0x414,
  0x415,
  0x416,
  0x418,
  0x41A,
  0x41B,
  0x41C,
  0x41D,
  0x41F,
  0x420,
  0x421,
  0x422,
  0x423,
  0x424,
  0x425,
  0x426,
  0x428,
  0x429,
  0x42D,
  0x42E,
  0x42F,
)

#let cyrnum = (..num) => {
  let num = num.pos()
  let rush(num) = {
    let sum = ""
    while num > 50 {
      let idx = calc.rem-euclid(num, 25) - 1
      sum += str.from-unicode(cyrill.at(idx))
      num -= 25
    }
    let idx = calc.rem-euclid(num, 25) - 1
    sum + str.from-unicode(cyrill.at(idx))
  }

  let rest = num.slice(1).map(elem => str(elem))
  let first = num.at(0)

  (rush(first), ..rest).join(".")
}
