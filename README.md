# 更改

原仓库：
将原代码的需要填入信息提取到单独文件中，并支持下载多个视频，只需填入多个即可。
将后续的手动使用命令合并文件操作合并到run.bat中。

## 使用

1. 根据info.js中的提示结合下面原readme的说明填入相关信息。
2. 运行run.bat

## 一些注意

默认将下载的视频文件夹命名为video${i}。
对应整合后的视频文件为video${i}.mp4并放到当前目录。

若运行过程中出现报错，可尝试将info.js中的needXor更改。

# 小鹅通视频下载使用说明

## 具体操作流程

1. 登录自己的网页版小鹅通，并打开相应视频界面
2. F12 在控制台输入 `userId` 查看自己的 userId，这个userId是用于得到真正的解密密钥的(可能，这个后续说明)
3. 打开F12的情况下，按下`shift+f5`刷新页面，并在network中找到 `.m3u8` 文件(这里可以用过滤只显示 .m3u8 相关的)，并把这个文件的 url 填写到 `m3u8Url` 中(完整路径带参数)
4. 同样在network中选中任意 `.ts` 文件，然后将路径填写到 `tsUrldemo` 中
5. ~~在本脚本的路径下，新建文件夹，并~~ 将 文件夹名称 填写到 `fileDir` 中
6. 执行脚本
7. 终端进入到 新建文件夹 中的 decode 目录中，执行 `ffmpeg -f concat -i filelist.txt -c copy output.mp4` 合并 `.ts` 文件并生成 `output.mp4` 完整的视频文件

## 原理流程

小鹅通的视频分片，一般是用 `aes128` 的密钥加密过的，这个可以看 `.m3u8` 文件，如果发生改变及时更改 `const decipher = crypto.createDecipheriv('aes-128-cbc', key, IV);`

而根据 `.m3u8` 得到的这个密钥也**可能是**经过二次加密的，是通过与 `userId` 异或得到

所以解密的流程就是：

```js
// 已知：
// userId
// m3u8Url
// ts分片拼接地址

// 获取m3u8文件
m3u8Msg = get_m3u8(m3u8Url)
// 提取keyURI
keyURI = getkeyURI(m3u8Msg)     // `#EXT-X-KEY:METHOD=AES-128,URI="keyURI",IV=0x00000000000000000000000000000000`
// 得到经过加密的key
key = getKey(keyURI)            // 一个16位的

// 异或得到用于解密的key, 这一步不一定需要，因为有可能通过 keyURI 得到的 key 就是最终解密的 key
realKey = key ^ userId          // userId 大于16位就截取前16位

// 下载经过加密的.ts视频文件
encode_tsFile = download(tsUrl) // m3u8 拼接后的
// 异或解密.ts视频
decode_tsFile = realKey ^ encode_tsFile

// 合并所有解密后的ts文件
ffmpegMerge(decode_tsFileLists)
```
