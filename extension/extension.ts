import * as vscode from "vscode";
import { exec } from "child_process";
import { writeFileSync, mkdirSync, existsSync, readFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";

const STATUS_DIR = join(homedir(), ".claude");
const STATUS_FILE = join(STATUS_DIR, "status.json");
const POLL_INTERVAL = 1000; // ms

let pollTimer: NodeJS.Timeout | null = null;

function writeStatus(state: string) {
  const data = JSON.stringify({ state, timestamp: Math.floor(Date.now() / 1000) });
  if (!existsSync(STATUS_DIR)) {
    mkdirSync(STATUS_DIR, { recursive: true });
  }
  writeFileSync(STATUS_FILE, data, "utf-8");
}

function checkClaudeProcess(): Promise<boolean> {
  return new Promise((resolve) => {
    exec("tasklist /FI \"IMAGENAME eq node.exe\" 2>nul", (err, stdout) => {
      if (err) { resolve(false); return; }
      // Check if any node process command line contains "claude"
      exec('wmic process where "name=\'node.exe\'" get commandline 2>nul', (err2, stdout2) => {
        if (err2) { resolve(false); return; }
        resolve(stdout2.toLowerCase().includes("claude"));
      });
    });
  });
}

function readStatusFile(): { state: string; timestamp: number } | null {
  try {
    if (existsSync(STATUS_FILE)) {
      return JSON.parse(readFileSync(STATUS_FILE, "utf-8"));
    }
  } catch {}
  return null;
}

const WAITING_TIMEOUT = 5000; // ms — switch yellow back to red if no hook fires within this

async function pollProcess() {
  const isRunning = await checkClaudeProcess();

  if (!isRunning) {
    writeStatus("stopped");
    return;
  }

  // Process is running — check current state
  const current = readStatusFile();

  if (!current || current.state === "stopped") {
    // Just started
    writeStatus("running");
    return;
  }

  // If hooks wrote "waiting" recently, keep it (yellow light)
  // If "waiting" is stale (no PreToolUse hook fired), revert to "running"
  if (current.state === "waiting") {
    const age = Date.now() - current.timestamp * 1000;
    if (age > WAITING_TIMEOUT) {
      writeStatus("running");
    }
  }
  // If "running", leave it alone — next Stop hook will set "waiting"
}

export function activate(context: vscode.ExtensionContext) {
  // Write initial stopped state
  writeStatus("stopped");

  pollTimer = setInterval(pollProcess, POLL_INTERVAL);

  const startCmd = vscode.commands.registerCommand("claude-traffic-light.start", () => {
    if (pollTimer) { clearInterval(pollTimer); }
    pollTimer = setInterval(pollProcess, POLL_INTERVAL);
    vscode.window.showInformationMessage("Claude Traffic Light: monitor started");
  });

  const stopCmd = vscode.commands.registerCommand("claude-traffic-light.stop", () => {
    if (pollTimer) {
      clearInterval(pollTimer);
      pollTimer = null;
    }
    writeStatus("stopped");
    vscode.window.showInformationMessage("Claude Traffic Light: monitor stopped");
  });

  context.subscriptions.push(startCmd, stopCmd);

  vscode.window.showInformationMessage("Claude Traffic Light: monitoring started");
}

export function deactivate() {
  if (pollTimer) {
    clearInterval(pollTimer);
    pollTimer = null;
  }
  writeStatus("stopped");
}
