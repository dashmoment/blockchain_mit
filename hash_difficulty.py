import hashlib

target_hex = "0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
target = int(target_hex, 16)

prefix = "jesse"  # 你也可以換成別的前綴
hits = []

for nonce in range(64):  # 0..63
    msg = f"{prefix}{nonce}".encode("utf-8")          # 字串拼接 -> bytes
    h = hashlib.sha256(msg).hexdigest()               # 單次 SHA-256（若要 double SHA-256 就再 sha256 一次）
    if int(h, 16) < target:
        hits.append((nonce, h))

print(f"Trials: 64, Target: 0x{target_hex}")
print(f"Hits: {len(hits)} (期待值約 64 * 1/16 = 4)")
for n, hx in hits:
    print(f"  nonce={n:2d}  hash=0x{hx}")