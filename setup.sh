#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRAVE_BROWSER=""

echo "==============================================="
echo "🚀 Setup Module Responsive Mobile + Brave"
echo "==============================================="

# Kiểm tra Node.js
if ! command -v node &> /dev/null; then
  echo "❌ Node.js không được cài đặt"
  echo "📥 Hãy tải từ: https://nodejs.org/"
  exit 1
fi

NODE_INSTALLED=$(node -v)
echo "✅ Node.js: $NODE_INSTALLED"

NPM_INSTALLED=$(npm -v)
echo "✅ npm: $NPM_INSTALLED"

# Kiểm tra Brave Browser
echo ""
echo "🔍 Tìm Brave Browser..."

if command -v brave &> /dev/null; then
  BRAVE_BROWSER=$(command -v brave)
  echo "✅ Brave: $BRAVE_BROWSER"
elif command -v brave-browser &> /dev/null; then
  BRAVE_BROWSER=$(command -v brave-browser)
  echo "✅ Brave (brave-browser): $BRAVE_BROWSER"
elif [ -f "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ]; then
  BRAVE_BROWSER="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
  echo "✅ Brave (macOS): $BRAVE_BROWSER"
elif [ -f "C:\\Program Files\\BraveSoftware\\Brave-Browser\\Application\\brave.exe" ]; then
  BRAVE_BROWSER="C:\\Program Files\\BraveSoftware\\Brave-Browser\\Application\\brave.exe"
  echo "✅ Brave (Windows): $BRAVE_BROWSER"
else
  echo "⚠️  Brave Browser không tìm thấy"
  echo "📥 Tải từ: https://brave.com"
fi

# Vào thư mục project
cd "$PROJECT_DIR"
echo ""
echo "📁 Project: $PROJECT_DIR"

# Xóa cache cũ
echo ""
echo "🧹 Xóa cache cũ..."
rm -rf node_modules .next dist build .vite .turbo
rm -rf .cache cache
rm -f package-lock.json

echo "✅ Cache đã xóa"

# Cài đặt packages
echo ""
echo "📦 Cài đặt dependencies..."
npm install --legacy-peer-deps

echo "✅ Dependencies installed"

# Tạo cấu trúc project
echo ""
echo "📝 Tạo cấu trúc project..."

mkdir -p src/components src/types src/utils public

# Tạo package.json nếu chưa có
if [ ! -f "$PROJECT_DIR/package.json" ]; then
  cat > package.json << 'EOF'
{
  "name": "responsive-mobile-module",
  "version": "1.0.0",
  "description": "Module nhạy màn, fix lag, tối ưu cho mobile",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "clean": "rm -rf node_modules dist .vite .next",
    "lint": "eslint src --ext .ts,.tsx"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "typescript": "^5.3.3",
    "vite": "^5.0.0",
    "@vitejs/plugin-react": "^4.2.0"
  }
}
EOF
  npm install --legacy-peer-deps
fi

# Tạo TypeScript config
if [ ! -f "$PROJECT_DIR/tsconfig.json" ]; then
  cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "resolveJsonModule": true,
    "jsx": "react-jsx",
    "jsxImportSource": "react"
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF
fi

# Tạo Vite config with Brave support
if [ ! -f "$PROJECT_DIR/vite.config.ts" ]; then
  cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    open: process.env.BRAVE_BROWSER ? false : true,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    minify: 'terser',
  },
})
EOF
fi

# Tạo main component
if [ ! -f "$PROJECT_DIR/src/MobileModule.tsx" ]; then
  cat > src/MobileModule.tsx << 'EOF'
import React, {
  memo,
  useCallback,
  useDeferredValue,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";

type Item = {
  id: number;
  label: string;
  category: string;
  price: number;
};

const DATA: Item[] = [
  { id: 1, label: "Sản phẩm A", category: "Điện tử", price: 120000 },
  { id: 2, label: "Sản phẩm B", category: "Thời trang", price: 240000 },
  { id: 3, label: "Sản phẩm C", category: "Gia dụng", price: 180000 },
  { id: 4, label: "Sản phẩm D", category: "Điện tử", price: 320000 },
  { id: 5, label: "Sản phẩm E", category: "Thời trang", price: 80000 },
  { id: 6, label: "Sản phẩm F", category: "Gia dụng", price: 500000 },
];

type ProductCardProps = {
  item: Item;
  selected: boolean;
  onSelect: (id: number) => void;
};

const ProductCard = memo(function ProductCard({
  item,
  selected,
  onSelect,
}: ProductCardProps) {
  return (
    <button
      type="button"
      onClick={() => onSelect(item.id)}
      style={{
        width: "100%",
        borderRadius: 14,
        border: selected ? "2px solid #2563eb" : "1px solid #dfe3ea",
        background: selected ? "#eff6ff" : "#ffffff",
        padding: 14,
        textAlign: "left",
        cursor: "pointer",
        boxShadow: selected ? "0 4px 12px rgba(37,99,235,0.12)" : "0 1px 2px rgba(0,0,0,0.04)",
        transition: "transform 120ms ease, box-shadow 120ms ease, border-color 120ms ease",
        WebkitTapHighlightColor: "transparent",
      }}
    >
      <div style={{ fontWeight: 700, color: "#111827" }}>{item.label}</div>
      <div style={{ marginTop: 6, color: "#6b7280", fontSize: 12 }}>{item.category}</div>
      <div style={{ marginTop: 10, fontWeight: 700, color: "#111827" }}>
        {item.price.toLocaleString("vi-VN")}đ
      </div>
    </button>
  );
});

export default function MobileOptimizedModule() {
  const [items] = useState<Item[]>(DATA);
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState<number | null>(1);
  const [isCompact, setIsCompact] = useState(false);
  const panelRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const node = panelRef.current;
    if (!node) return;

    const updateLayout = () => {
      requestAnimationFrame(() => {
        const width = node.getBoundingClientRect().width;
        setIsCompact(width < 520);
      });
    };

    const observer = new ResizeObserver(updateLayout);
    observer.observe(node);

    updateLayout();

    return () => observer.disconnect();
  }, []);

  const deferredQuery = useDeferredValue(query);

  const filteredItems = useMemo(() => {
    const q = deferredQuery.trim().toLowerCase();
    if (!q) return items;

    return items.filter(
      (item) =>
        item.label.toLowerCase().includes(q) ||
        item.category.toLowerCase().includes(q)
    );
  }, [items, deferredQuery]);

  const handleSelect = useCallback((id: number) => {
    setSelectedId((prev) => (prev === id ? prev : id));
  }, []);

  return (
    <div
      ref={panelRef}
      style={{
        width: "100%",
        maxWidth: 980,
        margin: "0 auto",
        padding: 16,
        borderRadius: 18,
        background: "#f8fafc",
        border: "1px solid #e5e7eb",
        contain: "layout paint style",
        WebkitOverflowScrolling: "touch",
      }}
    >
      <div
        style={{
          display: "flex",
          flexDirection: isCompact ? "column" : "row",
          alignItems: isCompact ? "stretch" : "center",
          justifyContent: "space-between",
          gap: 12,
          marginBottom: 16,
        }}
      >
        <h3 style={{ margin: 0, fontSize: 18, color: "#111827" }}>Danh sách sản phẩm</h3>

        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Tìm kiếm..."
          style={{
            width: isCompact ? "100%" : 220,
            height: 42,
            borderRadius: 12,
            border: "1px solid #d1d5db",
            padding: "0 12px",
            fontSize: 14,
            outline: "none",
            background: "#fff",
            color: "#111827",
          }}
        />
      </div>

      <div
        style={{
          display: "grid",
          gridTemplateColumns: isCompact ? "1fr" : "repeat(auto-fit, minmax(180px, 1fr))",
          gap: 12,
        }}
      >
        {filteredItems.map((item) => (
          <ProductCard
            key={item.id}
            item={item}
            selected={selectedId === item.id}
            onSelect={handleSelect}
          />
        ))}
      </div>

      {!filteredItems.length && (
        <div
          style={{
            marginTop: 16,
            padding: 14,
            textAlign: "center",
            color: "#6b7280",
            background: "#fff",
            borderRadius: 12,
            border: "1px dashed #d1d5db",
          }}
        >
          Không tìm thấy sản phẩm phù hợp.
        </div>
      )}
    </div>
  );
}
EOF
fi

# Tạo App.tsx
if [ ! -f "$PROJECT_DIR/src/App.tsx" ]; then
  cat > src/App.tsx << 'EOF'
import MobileOptimizedModule from './MobileModule'

export default function App() {
  return (
    <div style={{ minHeight: '100vh', background: '#f3f4f6', padding: '20px 0' }}>
      <MobileOptimizedModule />
    </div>
  )
}
EOF
fi

# Tạo main.tsx
if [ ! -f "$PROJECT_DIR/src/main.tsx" ]; then
  cat > src/main.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF
fi

# Tạo index.html
if [ ! -f "$PROJECT_DIR/index.html" ]; then
  cat > index.html << 'EOF'
<!doctype html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Module Responsive Mobile</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
          'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
          sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        background: #f3f4f6;
      }
    </style>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF
fi

echo "✅ Project structure created"

# Xây dựng
echo ""
echo "🔨 Build project..."
npm run build

echo ""
echo "==============================================="
echo "✅ Hoàn tất!"
echo "==============================================="
echo ""
echo "📌 Chạy dev server với Brave Browser:"
echo "   npm run dev:brave"
echo ""
echo "📌 Hoặc chạy bình thường:"
echo "   npm run dev"
echo ""
echo "📌 Build production:"
echo "   npm run build"
echo ""
echo "📌 Preview build:"
echo "   npm run preview"
echo ""

# Nếu tìm thấy Brave, chạy dev server
if [ -n "$BRAVE_BROWSER" ]; then
  echo "🌐 Mở Brave Browser..."
  sleep 2
  
  # Chạy dev server trong background
  BRAVE_BROWSER="$BRAVE_BROWSER" npm run dev &
  
  sleep 4
  
  # Mở URL trong Brave
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    "$BRAVE_BROWSER" http://localhost:5173 &
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    open -a "Brave Browser" http://localhost:5173
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    start "$BRAVE_BROWSER" http://localhost:5173
  fi
else
  echo "⚠️  Chạy bằng browser mặc định:"
  echo "   npm run dev"
fi

echo ""
