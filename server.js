require('dotenv').config();

const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();

const PORT = Number(process.env.PORT || 3000);
const JWT_SECRET =
  process.env.JWT_SECRET || 'lebrasil-chave-secreta-troque-em-producao';

app.use(cors());
app.use(express.json({ limit: '10mb' }));

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'mydb',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

function createToken(user) {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
    },
    JWT_SECRET,
    {
      expiresIn: '30d',
    }
  );
}

function authMiddleware(req, res, next) {
  const header = req.headers.authorization || '';

  const [type, token] = header.split(' ');

  if (type !== 'Bearer' || !token) {
    return res.status(401).json({
      error: 'Token não informado.',
    });
  }

  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (error) {
    return res.status(401).json({
      error: 'Token inválido ou expirado.',
    });
  }
}

async function getNextId(table, column) {
  const allowedTables = [
    'usuario',
    'login',
    'livros',
    'nivel',
    'ranking',
  ];

  if (!allowedTables.includes(table)) {
    throw new Error('Tabela não permitida.');
  }

  const [rows] = await pool.query(
    `SELECT COALESCE(MAX(${column}), 0) + 1 AS nextId FROM ${table}`
  );

  return Number(rows[0].nextId);
}

async function prepareDatabase() {
  try {
    await pool.query(`
      ALTER TABLE usuario
      ADD COLUMN profile_photo LONGTEXT NULL
    `);
  } catch (error) {}

  try {
    await pool.query(`
      ALTER TABLE usuario
      MODIFY senha1 VARCHAR(255) NOT NULL
    `);
  } catch (error) {
    console.log('Aviso senha1:', error.message);
  }

  try {
    await pool.query(`
      ALTER TABLE usuario
      MODIFY senha2 VARCHAR(255) NOT NULL
    `);
  } catch (error) {
    console.log('Aviso senha2:', error.message);
  }

  try {
    await pool.query(`
      ALTER TABLE login
      MODIFY senha VARCHAR(255) NOT NULL
    `);
  } catch (error) {
    console.log('Aviso senha login:', error.message);
  }

  try {
    await pool.query(`
      ALTER TABLE usuario
      DROP INDEX senha1_UNIQUE
    `);
  } catch (error) {}

  try {
    await pool.query(`
      ALTER TABLE usuario
      DROP INDEX senha2_UNIQUE
    `);
  } catch (error) {}

  try {
    await pool.query(`
      ALTER TABLE login
      DROP INDEX senha_UNIQUE
    `);
  } catch (error) {}

  await pool.query(`
    CREATE TABLE IF NOT EXISTS reading_progress (
      id INT NOT NULL AUTO_INCREMENT,
      user_id INT NOT NULL,
      book_id INT NOT NULL,
      progress DECIMAL(5,4) NOT NULL DEFAULT 0,
      position INT NOT NULL DEFAULT 0,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY unique_user_book (user_id, book_id),
      INDEX idx_user (user_id),
      INDEX idx_book (book_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);

  console.log('✓ Banco preparado.');
}

app.get('/', (req, res) => {
  res.json({
    ok: true,
    message: 'API lêBrasil funcionando.',
  });
});

app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');

    res.json({
      ok: true,
      database: 'connected',
      databaseName: process.env.DB_NAME || 'mydb',
    });
  } catch (error) {
    console.error('HEALTH:', error);

    res.status(500).json({
      ok: false,
      database: 'disconnected',
      error: error.message,
    });
  }
});

app.post('/api/auth/register', async (req, res) => {
  try {
    const {
      username,
      email,
      password,
      fullName,
      cpf,
    } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({
        error: 'Preencha usuário, email e senha.',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        error: 'A senha deve ter pelo menos 6 caracteres.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();
    const normalizedUsername = username.trim();

    const [emailExists] = await pool.query(
      `
      SELECT idcadastro
      FROM usuario
      WHERE email = ?
      LIMIT 1
      `,
      [normalizedEmail]
    );

    if (emailExists.length > 0) {
      return res.status(409).json({
        error: 'Este email já está cadastrado.',
      });
    }

    const [usernameExists] = await pool.query(
      `
      SELECT idcadastro
      FROM usuario
      WHERE nome_do_usuario = ?
      LIMIT 1
      `,
      [normalizedUsername]
    );

    if (usernameExists.length > 0) {
      return res.status(409).json({
        error: 'Este nome de usuário já está cadastrado.',
      });
    }

    const userCpf = cpf
      ? cpf.trim()
      : `NAO-INFORMADO-${Date.now()}`;

    const [cpfExists] = await pool.query(
      `
      SELECT idcadastro
      FROM usuario
      WHERE cpf = ?
      LIMIT 1
      `,
      [userCpf]
    );

    if (cpfExists.length > 0) {
      return res.status(409).json({
        error: 'Este CPF já está cadastrado.',
      });
    }

    const passwordHash = await bcrypt.hash(password, 12);

    const userId = await getNextId('usuario', 'idcadastro');
    const rankingId = await getNextId('ranking', 'idranking');
    const nivelId = await getNextId('nivel', 'idnivel');

    await pool.query(
      `
      INSERT INTO ranking (idranking)
      VALUES (?)
      `,
      [rankingId]
    );

    await pool.query(
      `
      INSERT INTO nivel (
        idnivel,
        pontuacao,
        progresso_de_evolucao,
        ranking_idranking
      )
      VALUES (?, 0, 0, ?)
      `,
      [nivelId, rankingId]
    );

    await pool.query(
      `
      INSERT INTO usuario (
        idcadastro,
        nome_do_usuario,
        email,
        cpf,
        senha1,
        senha2,
        usuario_idusuario,
        nivel_idnivel,
        nivel_ranking_idranking,
        profile_photo
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        userId,
        normalizedUsername,
        normalizedEmail,
        userCpf,
        passwordHash,
        passwordHash,
        userId,
        nivelId,
        rankingId,
        null,
      ]
    );

    const loginId = await getNextId('login', 'idLogin');

    await pool.query(
      `
      INSERT INTO login (
        idLogin,
        email,
        senha,
        usuario_idusuario,
        usuario_idcadastro,
        usuario_usuario_idusuario
      )
      VALUES (?, ?, ?, ?, ?, ?)
      `,
      [
        loginId,
        normalizedEmail,
        passwordHash,
        userId,
        userId,
        userId,
      ]
    );

    const user = {
      id: userId,
      username: normalizedUsername,
      email: normalizedEmail,
      fullName: fullName || null,
      profilePhoto: null,
    };

    return res.status(201).json({
      user,
      token: createToken(user),
    });
  } catch (error) {
    console.error('REGISTER:', error);

    return res.status(500).json({
      error: 'Erro ao cadastrar usuário.',
      details: error.message,
    });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        error: 'Informe email e senha.',
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    const [rows] = await pool.query(
      `
      SELECT
        idcadastro,
        nome_do_usuario,
        email,
        senha1,
        profile_photo
      FROM usuario
      WHERE email = ?
      LIMIT 1
      `,
      [normalizedEmail]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        error: 'Email ou senha incorretos.',
      });
    }

    const row = rows[0];

    const validPassword = await bcrypt.compare(
      password,
      row.senha1
    );

    if (!validPassword) {
      return res.status(401).json({
        error: 'Email ou senha incorretos.',
      });
    }

    const user = {
      id: row.idcadastro,
      username: row.nome_do_usuario,
      email: row.email,
      fullName: row.nome_do_usuario,
      profilePhoto: row.profile_photo,
    };

    return res.json({
      user,
      token: createToken(user),
    });
  } catch (error) {
    console.error('LOGIN:', error);

    return res.status(500).json({
      error: 'Erro ao fazer login.',
      details: error.message,
    });
  }
});

app.get('/api/auth/me', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(
      `
      SELECT
        idcadastro,
        nome_do_usuario,
        email,
        profile_photo
      FROM usuario
      WHERE idcadastro = ?
      LIMIT 1
      `,
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        error: 'Usuário não encontrado.',
      });
    }

    const row = rows[0];

    return res.json({
      id: row.idcadastro,
      username: row.nome_do_usuario,
      email: row.email,
      fullName: row.nome_do_usuario,
      profilePhoto: row.profile_photo,
    });
  } catch (error) {
    console.error('ME:', error);

    return res.status(500).json({
      error: 'Erro ao buscar usuário.',
    });
  }
});

app.put('/api/auth/profile', authMiddleware, async (req, res) => {
  try {
    const {
      fullName,
      username,
      email,
      password,
      profilePhoto,
    } = req.body;

    const normalizedEmail = email
      ? email.trim().toLowerCase()
      : null;

    if (normalizedEmail) {
      const [existingEmail] = await pool.query(
        `
        SELECT idcadastro
        FROM usuario
        WHERE email = ?
          AND idcadastro <> ?
        LIMIT 1
        `,
        [normalizedEmail, req.user.id]
      );

      if (existingEmail.length > 0) {
        return res.status(409).json({
          error: 'Este email já pertence a outra conta.',
        });
      }
    }

    if (username) {
      const [existingUsername] = await pool.query(
        `
        SELECT idcadastro
        FROM usuario
        WHERE nome_do_usuario = ?
          AND idcadastro <> ?
        LIMIT 1
        `,
        [username.trim(), req.user.id]
      );

      if (existingUsername.length > 0) {
        return res.status(409).json({
          error: 'Este nome de usuário já pertence a outra conta.',
        });
      }
    }

    const fields = [];
    const values = [];

    if (username) {
      fields.push('nome_do_usuario = ?');
      values.push(username.trim());
    }

    if (normalizedEmail) {
      fields.push('email = ?');
      values.push(normalizedEmail);
    }

    if (password && password.length > 0) {
      if (password.length < 6) {
        return res.status(400).json({
          error: 'A senha deve ter pelo menos 6 caracteres.',
        });
      }

      const passwordHash = await bcrypt.hash(password, 12);

      fields.push('senha1 = ?');
      values.push(passwordHash);

      fields.push('senha2 = ?');
      values.push(passwordHash);

      await pool.query(
        `
        UPDATE login
        SET senha = ?
        WHERE usuario_idcadastro = ?
        `,
        [passwordHash, req.user.id]
      );
    }

    if (profilePhoto !== undefined) {
      fields.push('profile_photo = ?');
      values.push(profilePhoto || null);
    }

    if (fields.length > 0) {
      values.push(req.user.id);

      await pool.query(
        `
        UPDATE usuario
        SET ${fields.join(', ')}
        WHERE idcadastro = ?
        `,
        values
      );
    }

    const [rows] = await pool.query(
      `
      SELECT
        idcadastro,
        nome_do_usuario,
        email,
        profile_photo
      FROM usuario
      WHERE idcadastro = ?
      LIMIT 1
      `,
      [req.user.id]
    );

    const row = rows[0];

    const user = {
      id: row.idcadastro,
      username: row.nome_do_usuario,
      email: row.email,
      fullName: row.nome_do_usuario,
      profilePhoto: row.profile_photo,
    };

    return res.json({
      user,
      token: createToken(user),
    });
  } catch (error) {
    console.error('PROFILE:', error);

    return res.status(500).json({
      error: 'Erro ao atualizar perfil.',
      details: error.message,
    });
  }
});

app.get('/api/books', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `
      SELECT
        idlivros,
        titulo,
        genero,
        autor,
        pdf
      FROM livros
      ORDER BY titulo ASC
      `
    );

    return res.json(rows);
  } catch (error) {
    console.error('BOOKS:', error);

    return res.status(500).json({
      error: 'Erro ao buscar livros.',
    });
  }
});

app.get('/api/books/my', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.query(
      `
      SELECT
        l.idlivros,
        l.titulo,
        l.genero,
        l.autor,
        l.pdf
      FROM livros l
      INNER JOIN usuario_has_livros uhl
        ON uhl.livros_idlivros = l.idlivros
      WHERE uhl.usuario_idcadastro = ?
      ORDER BY l.titulo ASC
      `,
      [req.user.id]
    );

    return res.json(rows);
  } catch (error) {
    console.error('MY BOOKS:', error);

    return res.status(500).json({
      error: 'Erro ao buscar livros do usuário.',
    });
  }
});

app.post('/api/books/:bookId/add', authMiddleware, async (req, res) => {
  try {
    const bookId = Number(req.params.bookId);

    if (!bookId) {
      return res.status(400).json({
        error: 'Livro inválido.',
      });
    }

    const [book] = await pool.query(
      `
      SELECT idlivros
      FROM livros
      WHERE idlivros = ?
      LIMIT 1
      `,
      [bookId]
    );

    if (book.length === 0) {
      return res.status(404).json({
        error: 'Livro não encontrado.',
      });
    }

    const [existing] = await pool.query(
      `
      SELECT *
      FROM usuario_has_livros
      WHERE usuario_idcadastro = ?
        AND livros_idlivros = ?
      LIMIT 1
      `,
      [req.user.id, bookId]
    );

    if (existing.length > 0) {
      return res.json({
        ok: true,
        message: 'Livro já está na conta.',
      });
    }

    const [user] = await pool.query(
      `
      SELECT
        usuario_idusuario,
        nivel_idnivel,
        nivel_ranking_idranking
      FROM usuario
      WHERE idcadastro = ?
      LIMIT 1
      `,
      [req.user.id]
    );

    if (user.length === 0) {
      return res.status(404).json({
        error: 'Usuário não encontrado.',
      });
    }

    const u = user[0];

    await pool.query(
      `
      INSERT INTO usuario_has_livros (
        usuario_idcadastro,
        usuario_usuario_idusuario,
        usuario_nivel_idnivel,
        usuario_nivel_ranking_idranking,
        livros_idlivros,
        livros_usuario_idusuario
      )
      VALUES (?, ?, ?, ?, ?, ?)
      `,
      [
        req.user.id,
        u.usuario_idusuario,
        u.nivel_idnivel,
        u.nivel_ranking_idranking,
        bookId,
        u.usuario_idusuario,
      ]
    );

    return res.status(201).json({
      ok: true,
      message: 'Livro adicionado à conta.',
    });
  } catch (error) {
    console.error('ADD BOOK:', error);

    return res.status(500).json({
      error: 'Erro ao adicionar livro.',
      details: error.message,
    });
  }
});

app.get('/api/reading/:bookId', authMiddleware, async (req, res) => {
  try {
    const bookId = Number(req.params.bookId);

    const [rows] = await pool.query(
      `
      SELECT
        progress,
        position,
        updated_at
      FROM reading_progress
      WHERE user_id = ?
        AND book_id = ?
      LIMIT 1
      `,
      [req.user.id, bookId]
    );

    if (rows.length === 0) {
      return res.json({
        progress: 0,
        position: 0,
      });
    }

    return res.json({
      progress: Number(rows[0].progress),
      position: Number(rows[0].position),
      updatedAt: rows[0].updated_at,
    });
  } catch (error) {
    console.error('GET PROGRESS:', error);

    return res.status(500).json({
      error: 'Erro ao buscar progresso.',
    });
  }
});

app.put('/api/reading/:bookId', authMiddleware, async (req, res) => {
  try {
    const bookId = Number(req.params.bookId);

    let progress = Number(req.body.progress || 0);
    let position = Number(req.body.position || 0);

    progress = Math.max(0, Math.min(1, progress));
    position = Math.max(0, position);

    await pool.query(
      `
      INSERT INTO reading_progress (
        user_id,
        book_id,
        progress,
        position
      )
      VALUES (?, ?, ?, ?)

      ON DUPLICATE KEY UPDATE
        progress = VALUES(progress),
        position = VALUES(position),
        updated_at = CURRENT_TIMESTAMP
      `,
      [
        req.user.id,
        bookId,
        progress,
        position,
      ]
    );

    return res.json({
      ok: true,
      progress,
      position,
    });
  } catch (error) {
    console.error('SAVE PROGRESS:', error);

    return res.status(500).json({
      error: 'Erro ao salvar progresso.',
      details: error.message,
    });
  }
});

app.post('/api/auth/logout', authMiddleware, (req, res) => {
  return res.json({
    ok: true,
    message: 'Logout realizado. Remova o token salvo no aplicativo.',
  });
});

app.use((error, req, res, next) => {
  console.error('ERRO INTERNO:', error);

  return res.status(500).json({
    error: 'Erro interno do servidor.',
  });
});

async function startServer() {
  try {
    await pool.query('SELECT 1');

    console.log('✓ MySQL conectado.');
    console.log(`✓ Banco: ${process.env.DB_NAME || 'mydb'}`);

    await prepareDatabase();

    app.listen(PORT, '0.0.0.0', () => {
      console.log('');
      console.log(`✓ API lêBrasil rodando na porta ${PORT}`);
      console.log(`✓ PC: http://localhost:${PORT}`);
      console.log(`✓ Health: http://localhost:${PORT}/api/health`);
      console.log('');
    });
  } catch (error) {
    console.error('');
    console.error('✗ Não foi possível iniciar o servidor.');
    console.error('');
    console.error(error.message);
    console.error('');
  }
}

startServer();