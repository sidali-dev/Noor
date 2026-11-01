import type * as React from 'react';

export type IconName = 'home' | 'compass' | 'calendar' | 'bookmark' | 'settings' | 'moon' | 'star' | 'search' | 'bell' | 'check' | 'alert' | 'plus';

export interface IconProps { name: IconName; size?: number; strokeWidth?: number; label?: string; className?: string }
export declare function Icon(props: IconProps): React.ReactElement;

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'md' | 'sm';
  icon?: IconName;
}
export declare function Button(props: ButtonProps): React.ReactElement;

export interface PaperCardProps extends React.HTMLAttributes<HTMLElement> {
  elevation?: 1 | 2 | 3;
  tone?: 'paper' | 'night';
  eyebrow?: React.ReactNode;
  title?: React.ReactNode;
  children?: React.ReactNode;
}
export declare function PaperCard(props: PaperCardProps): React.ReactElement;

export interface ArchFrameProps {
  /** px; height follows the 240:266 artwork */
  width?: number;
  /** number of nested paper frames, front to back */
  layers?: 1 | 2 | 3;
  children?: React.ReactNode;
  /** CSS length from the top of the figure to the content block; default 42% */
  contentTop?: string;
  label?: string;
  moon?: boolean;
  glow?: boolean;
  stars?: boolean;
  skyline?: boolean;
  clouds?: boolean;
  lace?: boolean;
  className?: string;
  style?: React.CSSProperties;
}
export declare function ArchFrame(props: ArchFrameProps): React.ReactElement;

export interface BadgeProps { tone?: 'neutral' | 'night' | 'brass' | 'success' | 'danger'; icon?: IconName; children?: React.ReactNode; className?: string }
export declare function Badge(props: BadgeProps): React.ReactElement;

export interface TextFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  hint?: string;
  error?: string;
}
export declare function TextField(props: TextFieldProps): React.ReactElement;

export interface ToggleProps { label?: React.ReactNode; checked?: boolean; defaultChecked?: boolean; onChange?: (checked: boolean) => void; disabled?: boolean; className?: string }
export declare function Toggle(props: ToggleProps): React.ReactElement;

export interface TabBarItem { id: string; label: string; icon: IconName }
export interface TabBarProps { items: TabBarItem[]; active?: string; defaultActive?: string; onChange?: (id: string) => void; label?: string; className?: string }
export declare function TabBar(props: TabBarProps): React.ReactElement;

export interface OrnamentProps { label?: string; className?: string }
export declare function Ornament(props: OrnamentProps): React.ReactElement;

declare global {
  interface Window {
    Hilal: { Button: typeof Button; PaperCard: typeof PaperCard; ArchFrame: typeof ArchFrame; Badge: typeof Badge; TextField: typeof TextField; Toggle: typeof Toggle; TabBar: typeof TabBar; Ornament: typeof Ornament; Icon: typeof Icon };
  }
}
