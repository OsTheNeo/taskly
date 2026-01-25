import { SVGProps } from "react";

// Base props for all icons
interface IconProps extends SVGProps<SVGSVGElement> {
  size?: number | string;
}

// Helper to get icon styles - accent color comes from CSS variable
const getAccentFill = (opacity: number = 0.3) =>
  `rgba(var(--accent-rgb), ${opacity})`;

// ============================================
// Navigation Icons
// ============================================

export function IconHome({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M3.145 5.95L8.395 1.96C8.753 1.688 9.248 1.688 9.605 1.96L14.855 5.95C15.104 6.139 15.25 6.434 15.25 6.746V14.25C15.25 15.355 14.355 16.25 13.25 16.25H4.75C3.645 16.25 2.75 15.355 2.75 14.25V6.746C2.75 6.433 2.896 6.139 3.145 5.95Z"
        className="fill-primary/30"
      />
      <path
        d="M9 16V12.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M3.145 5.95L8.395 1.96C8.753 1.688 9.248 1.688 9.605 1.96L14.855 5.95C15.104 6.139 15.25 6.434 15.25 6.746V14.25C15.25 15.355 14.355 16.25 13.25 16.25H4.75C3.645 16.25 2.75 15.355 2.75 14.25V6.746C2.75 6.433 2.896 6.139 3.145 5.95Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconRocket({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M13.1707 10.0588C16.6759 6.381 16.2472 2.0942 16.2108 1.7892C15.9049 1.7528 11.619 1.3241 7.94118 4.8293C5.71338 6.9526 4.96349 9.3233 4.74579 10.1164L7.88368 13.2543C8.67678 13.0366 11.0474 12.2865 13.1707 10.0588Z"
        className="fill-primary/30"
      />
      <path
        d="M11.75 7.5C12.44 7.5 13 6.9404 13 6.25C13 5.5596 12.44 5 11.75 5C11.06 5 10.5 5.5596 10.5 6.25C10.5 6.9404 11.06 7.5 11.75 7.5Z"
        fill="currentColor"
      />
      <path
        d="M2.85699 12.4692C2.20309 12.7981 1.75 13.468 1.75 14.25V16.25H3.75C4.5317 16.25 5.2016 15.7971 5.5305 15.1433"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M13.1707 10.0588C16.6759 6.381 16.2472 2.0942 16.2108 1.7892C15.9049 1.7528 11.619 1.3241 7.94118 4.8293C5.71338 6.9526 4.96349 9.3233 4.74579 10.1164L7.88368 13.2543C8.67678 13.0366 11.0474 12.2865 13.1707 10.0588Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M8.26601 4.5279L6.892 4.2819C5.637 4.0569 4.737 3.959 4 5L1.75 8.2699C1.75 8.2699 3.3528 7.6568 5.5921 7.9669"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M10.033 12.4078C10.3431 14.647 9.72998 16.2499 9.72998 16.2499L13 14C14.041 13.263 13.943 12.3629 13.718 11.1079L13.472 9.7339"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconUser({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M9 7.25C10.5188 7.25 11.75 6.01878 11.75 4.5C11.75 2.98122 10.5188 1.75 9 1.75C7.48122 1.75 6.25 2.98122 6.25 4.5C6.25 6.01878 7.48122 7.25 9 7.25Z"
        className="fill-primary/30"
      />
      <path
        d="M9 7.25C10.5188 7.25 11.75 6.01878 11.75 4.5C11.75 2.98122 10.5188 1.75 9 1.75C7.48122 1.75 6.25 2.98122 6.25 4.5C6.25 6.01878 7.48122 7.25 9 7.25Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M13.762 15.516C14.622 15.245 15.074 14.295 14.709 13.471C13.739 11.28 11.55 9.75 8.99999 9.75C6.44999 9.75 4.26099 11.28 3.29099 13.471C2.92599 14.296 3.37799 15.245 4.23799 15.516C5.46299 15.902 7.08399 16.25 8.99999 16.25C10.916 16.25 12.537 15.902 13.762 15.516Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconUsers({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M16.494 11.3635C16.688 11.8785 16.381 12.4475 15.858 12.6225C14.9814 12.9153 13.8077 13.1965 12.4107 13.2436C12.3924 13.1857 12.3724 13.1278 12.3506 13.0698C11.7793 11.5536 10.6789 10.2859 9.2969 9.47266C8.65208 9.09318 11.7223 8.25153 12 8.25153C14.058 8.25153 15.809 9.54552 16.494 11.3635Z"
        className="fill-primary/30"
      />
      <path
        d="M12 5.75C13.1046 5.75 14 4.85457 14 3.75C14 2.64543 13.1046 1.75 12 1.75C10.8954 1.75 10 2.64543 10 3.75C10 4.85457 10.8954 5.75 12 5.75Z"
        className="fill-primary/30"
      />
      <path
        d="M5.75 8.25C6.85457 8.25 7.75 7.35457 7.75 6.25C7.75 5.14543 6.85457 4.25 5.75 4.25C4.64543 4.25 3.75 5.14543 3.75 6.25C3.75 7.35457 4.64543 8.25 5.75 8.25Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M9.60903 15.122C10.132 14.947 10.439 14.378 10.245 13.863C9.56003 12.045 7.80903 10.751 5.75103 10.751C3.69303 10.751 1.94203 12.045 1.25703 13.863C1.06303 14.379 1.37003 14.948 1.89303 15.122C2.85503 15.443 4.17403 15.75 5.75203 15.75C7.33003 15.75 8.64803 15.443 9.60903 15.122Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M12 5.75C13.1046 5.75 14 4.85457 14 3.75C14 2.64543 13.1046 1.75 12 1.75C10.8954 1.75 10 2.64543 10 3.75C10 4.85457 10.8954 5.75 12 5.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M13.154 13.1873C14.2224 13.0845 15.1437 12.8614 15.858 12.6226C16.381 12.4476 16.688 11.8785 16.494 11.3636C15.809 9.54552 14.058 8.25153 12 8.25153C11.1608 8.25153 10.379 8.47713 9.69287 8.85553"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconChartBar({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M14.75 2.75H14.25C13.6977 2.75 13.25 3.19772 13.25 3.75V14.25C13.25 14.8023 13.6977 15.25 14.25 15.25H14.75C15.3023 15.25 15.75 14.8023 15.75 14.25V3.75C15.75 3.19772 15.3023 2.75 14.75 2.75Z"
        className="fill-primary/30"
      />
      <path
        d="M9.25 7.75H8.75C8.19772 7.75 7.75 8.19772 7.75 8.75V14.25C7.75 14.8023 8.19772 15.25 8.75 15.25H9.25C9.80228 15.25 10.25 14.8023 10.25 14.25V8.75C10.25 8.19772 9.80228 7.75 9.25 7.75Z"
        className="fill-primary/30"
      />
      <path
        d="M3.75 11.75H3.25C2.69772 11.75 2.25 12.1977 2.25 12.75V14.25C2.25 14.8023 2.69772 15.25 3.25 15.25H3.75C4.30228 15.25 4.75 14.8023 4.75 14.25V12.75C4.75 12.1977 4.30228 11.75 3.75 11.75Z"
        className="fill-primary/30"
      />
      <path
        d="M14.75 2.75H14.25C13.6977 2.75 13.25 3.19772 13.25 3.75V14.25C13.25 14.8023 13.6977 15.25 14.25 15.25H14.75C15.3023 15.25 15.75 14.8023 15.75 14.25V3.75C15.75 3.19772 15.3023 2.75 14.75 2.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M9.25 7.75H8.75C8.19772 7.75 7.75 8.19772 7.75 8.75V14.25C7.75 14.8023 8.19772 15.25 8.75 15.25H9.25C9.80228 15.25 10.25 14.8023 10.25 14.25V8.75C10.25 8.19772 9.80228 7.75 9.25 7.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M3.75 11.75H3.25C2.69772 11.75 2.25 12.1977 2.25 12.75V14.25C2.25 14.8023 2.69772 15.25 3.25 15.25H3.75C4.30228 15.25 4.75 14.8023 4.75 14.25V12.75C4.75 12.1977 4.30228 11.75 3.75 11.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M6.25 2.75H8.75V5.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M8.5 3L2.75 8.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

// ============================================
// Action Icons
// ============================================

export function IconPlus({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M9 3.25V14.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M3.25 9H14.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconTrash({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        opacity="0.3"
        d="M13.605 4.75L13.099 14.35C13.043 15.4201 12.1651 16.25 11.1021 16.25H6.89705C5.83305 16.25 4.95604 15.42 4.90004 14.35L4.39404 4.75"
        className="fill-primary"
      />
      <path
        d="M2.75 4.75H15.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M6.75 4.75V2.75C6.75 2.2 7.198 1.75 7.75 1.75H10.25C10.802 1.75 11.25 2.2 11.25 2.75V4.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M13.8557 4.75L13.35 14.35C13.294 15.4201 12.416 16.25 11.353 16.25H6.64796C5.58396 16.25 4.70697 15.42 4.65097 14.35L4.14526 4.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconCheck({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M2.75 9.25L6.75 14.25L15.25 3.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconX({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M14 4L4 14"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M4 4L14 14"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

// ============================================
// UI Icons
// ============================================

export function IconTarget({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M9 9L12.25 5.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        opacity="0.3"
        d="M12.25 5.75L11.5 3.5L14 1L14.75 3.25L17 4L14.5 6.5L12.25 5.75Z"
        className="fill-primary"
      />
      <path
        d="M12.25 5.75L11.5 3.5L14 1L14.75 3.25L17 4L14.5 6.5L12.25 5.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        opacity="0.3"
        fillRule="evenodd"
        clipRule="evenodd"
        d="M15.8279 8.31689C15.445 8.59829 14.9842 8.75 14.5 8.75C14.2578 8.75 14.0186 8.71087 13.7886 8.63427L13.5039 8.53943L13.2149 8.62817C13.2403 8.81587 13.25 8.805 13.25 9C13.25 11.3469 11.3472 13.25 8.99998 13.25C6.65278 13.25 4.74998 11.3469 4.74998 9C4.74998 6.6531 6.65278 4.75 8.99998 4.75C9.18968 4.75 9.16978 4.73267 9.35288 4.75677L9.45618 4.48321L9.36558 4.21142C9.13578 3.52282 9.24988 2.7848 9.65828 2.2066C9.73228 2.1018 9.64698 1.75 9.64698 1.75C9.32148 1.7051 9.33768 1.75 8.99988 1.75C4.99588 1.75 1.74988 4.9961 1.74988 9C1.74988 13.0039 4.99588 16.25 8.99988 16.25C13.0039 16.25 16.2499 13.0039 16.2499 9C16.2499 8.6621 16.2681 8.60388 16.2234 8.27838C16.2234 8.27838 15.9203 8.24899 15.8279 8.31689Z"
        className="fill-primary"
      />
      <path
        d="M8.757 4.75677C6.5231 4.88277 4.75 6.7346 4.75 9C4.75 11.3469 6.653 13.25 9 13.25C11.2653 13.25 13.1171 11.477 13.2432 9.24323"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M9.0633 1.75031C9.0422 1.75011 9.0212 1.75 9 1.75C4.996 1.75 1.75 4.9961 1.75 9C1.75 13.0039 4.996 16.25 9 16.25C13.004 16.25 16.25 13.0039 16.25 9C16.25 8.9788 16.2499 8.95772 16.2497 8.93652"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconFlame({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M14.5 10.733C14.5 13.78 12.038 16.25 9 16.25C10.519 16.25 11.75 15.015 11.75 13.491C11.75 11.395 9 9 9 9C9 9 6.25 11.396 6.25 13.491C6.25 15.015 7.481 16.25 9 16.25C5.962 16.25 3.5 13.78 3.5 10.733C3.5 6.542 9 1.75 9 1.75C9 1.75 14.5 6.542 14.5 10.733Z"
        className="fill-primary/30"
      />
      <path
        d="M9 16.25C10.519 16.25 11.75 15.015 11.75 13.491C11.75 11.395 9 9 9 9C9 9 6.25 11.396 6.25 13.491C6.25 15.015 7.481 16.25 9 16.25Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M9 16.25C12.038 16.25 14.5 13.78 14.5 10.733C14.5 6.542 9 1.75 9 1.75C9 1.75 3.5 6.542 3.5 10.733C3.5 13.78 5.962 16.25 9 16.25Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconGear({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M9 14.5C12.0376 14.5 14.5 12.0376 14.5 9C14.5 5.96243 12.0376 3.5 9 3.5C5.96243 3.5 3.5 5.96243 3.5 9C3.5 12.0376 5.96243 14.5 9 14.5Z"
        className="fill-primary/30"
      />
      <path d="M6.25 4.237L9 9" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M6.25 13.764L9 9" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M14.5 9H9" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M9 14.5C12.0376 14.5 14.5 12.0376 14.5 9C14.5 5.96243 12.0376 3.5 9 3.5C5.96243 3.5 3.5 5.96243 3.5 9C3.5 12.0376 5.96243 14.5 9 14.5Z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M9 1.75V3.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M2.72101 5.375L4.23701 6.25" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M1.75 9H3.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M16.25 9H14.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M2.72101 12.625L4.23701 11.75" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M9 16.25V14.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M12.625 15.279L11.75 13.763" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M5.375 15.279L6.25 13.763" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M15.279 12.625L13.763 11.75" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M15.279 5.375L13.763 6.25" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M12.625 2.721L11.75 4.237" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
      <path d="M5.375 2.721L6.25 4.237" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" fill="none" />
    </svg>
  );
}

export function IconSparkle({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="m11.24,6.289l-2.24-4.539-2.24,4.539-5.01.728,3.625,3.534-.856,4.989,4.3006-2.1125.31-.1744c.2095-.5502.6568-.9927,1.2371-1.1861l.5514-.1839.1849-.5546c.3338-.994,1.2606-1.3285,1.8965-1.3285.0584,0,.1192.0028.1818.0087l3.0687-2.9917-5.01-.728Z"
        fillRule="evenodd"
        className="fill-primary/30"
      />
      <path
        d="m4.743,2.492l-.946-.315-.316-.947c-.102-.306-.609-.306-.711,0l-.316.947-.946.315c-.153.051-.257.194-.257.356s.104.305.257.356l.946.315.316.947c.051.153.194.256.355.256s.305-.104.355-.256l.316-.947.946-.315c.153-.051.257-.194.257-.356s-.104-.305-.257-.356h.001Z"
        fill="currentColor"
      />
      <polyline
        points="13.8297 9.3765 16.25 7.0171 11.24 6.29 9 1.75 6.76 6.29 1.75 7.0171 5.375 10.551 4.519 15.54 8.2808 13.5625"
        fill="none"
        stroke="currentColor"
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeWidth="1.5"
      />
      <path
        d="m15.158,13.49l-1.263-.421-.421-1.263c-.137-.408-.812-.408-.949,0l-.421,1.263-1.263.421c-.204.068-.342.259-.342.474s.138.406.342.474l1.263.421.421,1.263c.068.204.26.342.475.342s.406-.138.475-.342l.421-1.263,1.263-.421c.204-.068.342-.259.342-.474s-.138-.406-.342-.474h-.001Z"
        fill="currentColor"
      />
      <circle cx="14.25" cy="3.25" r=".75" fill="currentColor" />
    </svg>
  );
}

export function IconChevronRight({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M6.5 2.75L12.75 9L6.5 15.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconMoreVertical({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <circle cx="9" cy="4" r="1.25" fill="currentColor" />
      <circle cx="9" cy="9" r="1.25" fill="currentColor" />
      <circle cx="9" cy="14" r="1.25" fill="currentColor" />
    </svg>
  );
}

export function IconCalendar({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <rect
        x="2.25"
        y="3.25"
        width="13.5"
        height="12.5"
        rx="2"
        className="fill-primary/30"
      />
      <rect
        x="2.25"
        y="3.25"
        width="13.5"
        height="12.5"
        rx="2"
        stroke="currentColor"
        strokeWidth="1.5"
        fill="none"
      />
      <path
        d="M2.25 7.25H15.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M5.75 1.75V4.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M12.25 1.75V4.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}

export function IconCheckCircle({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <circle cx="9" cy="9" r="7.25" className="fill-primary/30" />
      <circle
        cx="9"
        cy="9"
        r="7.25"
        stroke="currentColor"
        strokeWidth="1.5"
        fill="none"
      />
      <path
        d="M5.75 9L8 11.25L12.25 6.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconLoader({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={`animate-spin ${className || ""}`}
      {...props}
    >
      <path
        d="M9 1.75V4.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
      <path
        d="M9 13.75V16.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        opacity="0.3"
      />
      <path
        d="M1.75 9H4.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        opacity="0.5"
      />
      <path
        d="M13.75 9H16.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        opacity="0.7"
      />
      <path
        d="M3.87 3.87L5.64 5.64"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        opacity="0.6"
      />
      <path
        d="M12.36 12.36L14.13 14.13"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        opacity="0.4"
      />
      <path
        d="M3.87 14.13L5.64 12.36"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        opacity="0.4"
      />
      <path
        d="M12.36 5.64L14.13 3.87"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        opacity="0.8"
      />
    </svg>
  );
}

export function IconLogOut({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M7.25 2.75H4.75C3.64543 2.75 2.75 3.64543 2.75 4.75V13.25C2.75 14.3546 3.64543 15.25 4.75 15.25H7.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M11.75 12.25L15.25 9L11.75 5.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M15.25 9H6.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconSun({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <circle cx="9" cy="9" r="3.25" className="fill-primary/30" />
      <circle cx="9" cy="9" r="3.25" stroke="currentColor" strokeWidth="1.5" fill="none" />
      <path d="M9 1.75V3.25" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M9 14.75V16.25" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M1.75 9H3.25" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M14.75 9H16.25" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M3.87 3.87L4.93 4.93" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M13.07 13.07L14.13 14.13" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M3.87 14.13L4.93 13.07" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
      <path d="M13.07 4.93L14.13 3.87" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function IconMoon({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M15.5 10.5C14.7 13.1 12.1 15 9 15C5.1 15 2 11.9 2 8C2 4.9 3.9 2.3 6.5 1.5C5.6 3 5 4.8 5 6.8C5 11 8.3 14.4 12.5 14.5C13.5 14.5 14.6 14.2 15.5 13.8V10.5Z"
        className="fill-primary/30"
      />
      <path
        d="M15.5 10.5C14.7 13.1 12.1 15 9 15C5.1 15 2 11.9 2 8C2 4.9 3.9 2.3 6.5 1.5C5.6 3 5 4.8 5 6.8C5 11 8.3 14.4 12.5 14.5C13.5 14.5 14.6 14.2 15.5 10.5Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconGlobe({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <circle cx="9" cy="9" r="7.25" className="fill-primary/30" />
      <circle cx="9" cy="9" r="7.25" stroke="currentColor" strokeWidth="1.5" fill="none" />
      <ellipse cx="9" cy="9" rx="3.25" ry="7.25" stroke="currentColor" strokeWidth="1.5" fill="none" />
      <path d="M2 9H16" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}

export function IconBell({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M14.25 12.25V8C14.25 5.1 11.9 2.75 9 2.75C6.1 2.75 3.75 5.1 3.75 8V12.25L2.25 14.25H15.75L14.25 12.25Z"
        className="fill-primary/30"
      />
      <path
        d="M14.25 12.25V8C14.25 5.1 11.9 2.75 9 2.75C6.1 2.75 3.75 5.1 3.75 8V12.25L2.25 14.25H15.75L14.25 12.25Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M7 14.25C7 15.35 7.9 16.25 9 16.25C10.1 16.25 11 15.35 11 14.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconCopy({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <rect x="6.25" y="6.25" width="9.5" height="9.5" rx="1.5" className="fill-primary/30" />
      <rect x="6.25" y="6.25" width="9.5" height="9.5" rx="1.5" stroke="currentColor" strokeWidth="1.5" fill="none" />
      <path
        d="M11.75 6.25V4.25C11.75 3.42 11.08 2.75 10.25 2.75H4.25C3.42 2.75 2.75 3.42 2.75 4.25V10.25C2.75 11.08 3.42 11.75 4.25 11.75H6.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconLink({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M7.5 10.5L10.5 7.5"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12.75 10.75L14.25 9.25C15.35 8.15 15.35 6.35 14.25 5.25V5.25C13.15 4.15 11.35 4.15 10.25 5.25L8.75 6.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M5.25 7.25L3.75 8.75C2.65 9.85 2.65 11.65 3.75 12.75V12.75C4.85 13.85 6.65 13.85 7.75 12.75L9.25 11.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconTrophy({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M5.25 2.75H12.75V8C12.75 10.07 11.07 11.75 9 11.75C6.93 11.75 5.25 10.07 5.25 8V2.75Z"
        className="fill-primary/30"
      />
      <path
        d="M5.25 2.75H12.75V8C12.75 10.07 11.07 11.75 9 11.75C6.93 11.75 5.25 10.07 5.25 8V2.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M9 11.75V14.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M6.25 16.25H11.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M5.25 5.75H3.75C2.92 5.75 2.25 5.08 2.25 4.25C2.25 3.42 2.92 2.75 3.75 2.75H5.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M12.75 5.75H14.25C15.08 5.75 15.75 5.08 15.75 4.25C15.75 3.42 15.08 2.75 14.25 2.75H12.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconStar({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M9 1.75L11.24 6.29L16.25 7.02L12.63 10.55L13.48 15.54L9 13.19L4.52 15.54L5.37 10.55L1.75 7.02L6.76 6.29L9 1.75Z"
        className="fill-primary/30"
      />
      <path
        d="M9 1.75L11.24 6.29L16.25 7.02L12.63 10.55L13.48 15.54L9 13.19L4.52 15.54L5.37 10.55L1.75 7.02L6.76 6.29L9 1.75Z"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

// Category specific icons
export function IconBook({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M2.75 4.25C2.75 3.14543 3.64543 2.25 4.75 2.25H15.25V12.25H2.75V4.25Z"
        className="fill-primary/30"
      />
      <path
        d="M2.75 14V4.25C2.75 3.145 3.645 2.25 4.75 2.25H15.25V12.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M5.25 15.75H4.5C3.534 15.75 2.75 14.967 2.75 14C2.75 13.033 3.534 12.25 4.5 12.25H15.25C14.609 13.094 14.516 14.797 15.25 15.75H12.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconActivity({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <path
        d="M1.75 9H4.5L6.5 14.25L11.5 3.75L13.5 9H16.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
    </svg>
  );
}

export function IconBriefcase({ size = 18, className, ...props }: IconProps) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 18 18"
      className={className}
      {...props}
    >
      <rect x="2.25" y="5.25" width="13.5" height="10.5" rx="2" className="fill-primary/30" />
      <rect x="2.25" y="5.25" width="13.5" height="10.5" rx="2" stroke="currentColor" strokeWidth="1.5" fill="none" />
      <path
        d="M6.25 5.25V4.25C6.25 3.15 7.15 2.25 8.25 2.25H9.75C10.85 2.25 11.75 3.15 11.75 4.25V5.25"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
        fill="none"
      />
      <path
        d="M2.25 10.25H15.75"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  );
}
